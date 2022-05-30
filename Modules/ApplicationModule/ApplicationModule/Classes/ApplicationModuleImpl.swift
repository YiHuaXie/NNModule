import Foundation
import NNModule_swift
import SafariServices
import ModuleServices

extension Module.RegisterService {
    
    @objc static func applicationModule() {
        Module.register(service: ModuleApplicationService.self, used: ApplicationModuleImpl.self)
    }
}

extension Module.Awake {
    
    @objc static func applicationModule() {
        if let cls = NSClassFromString("TabBarController.TabBarController"),
           let tabBarType = cls as? UITabBarController.Type {
            Module.tabService.tabBarControllerType = tabBarType
        }
        
        Module.routeService.update(defaultScheme: "app")
        Module.routeService.registerRoute(Module.routeService.webLink) { url, navigator in
            guard let string = url.parameters["url"] as? String, let url = URL(string: string) else {
                return false
            }
            
            navigator.push(SFSafariViewController(url: url))
            return true
        }
    }
}

class ApplicationModuleImpl: NSObject, ModuleApplicationService {
    
    static var implPriority: Int { 100 }
    
    var window: UIWindow?
    
    required override init() {
        super.init()
        
        Module.service(of: LoginService.self).loginMulticast.registerTarget(self)
        [LoginNotification.didLoginSuccess, LoginNotification.didLogoutSuccess].forEach {
            Module.notificationeService
                .observe(name: $0.rawValue) { [weak self] _ in self?.reloadMainViewController() }
                .disposed(by: self)
        }
    }
    
//    func application(
//        _ application: UIApplication,
//        willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
//    ) -> Bool {
//        window = UIWindow(frame: UIScreen.main.bounds)
//        window?.backgroundColor = .red
//
//        return true
//    }
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?
    ) -> Bool {
        setupAppearance()
        reloadMainViewController()
       
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("\(type(of: self)): \(#function)")
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("\(type(of: self)): \(#function)")
    }
    
    func application(
        _ app: UIApplication,
        open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        if let scheme = url.scheme?.lowercased(), scheme == Module.routeService.defaultScheme  {
            var newOptions = [String: Any]()
            options.forEach { newOptions[$0.rawValue] = $1 }
            
            return Module.routeService.openRoute(url.absoluteString, parameters: newOptions)
        }
        
        return false
    }
    
    func reloadMainViewController() {
        let loginImpl = Module.service(of: LoginService.self)
        let viewController: UIViewController = loginImpl.isLogin ? Module.tabService.tabBarController : loginImpl.loginMain
        window?.rootViewController = viewController
    }
}

extension ApplicationModuleImpl: LoginEvent {
    
    func didLoginSuccess() {
        debugPrint("\(self) \(#function)")
    }
    
    func didLogoutSuccess() {
        debugPrint("\(self) \(#function)")
    }
}

private extension ApplicationModuleImpl {
    
    func setupAppearance() {}
}
