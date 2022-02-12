import Foundation
import NNModule
import SafariServices
import ModuleServices

extension Module.Awake {
    
    @objc static func applicationAwake() {
        
        
        let webLink = Module.routeService.webLink
        Module.routeService.registerRoute(webLink) { url, navigator in
            guard let urlString = url.parameters["url"] as? String, let url = URL(string: urlString) else {
                return false
            }

            navigator.push(SFSafariViewController(url: url))

            return true
        }
    }
}

class ApplicationModuleImpl: NSObject, ModuleApplicationService {
    
    required override init() {
        super.init()
        Module.routeService.update(defaultScheme: "app")
        
        [LoginNotice.didLoginSuccess, LoginNotice.didLogoutSuccess]
        .map { Notification.Name($0.rawValue) }
        .forEach {
            Module.noticeService.observe(name: $0) { [weak self] _ in self?.reloadMainViewController() }
            .disposed(by: self)
        }
    }
    
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
        
        if let delegate = UIApplication.shared.delegate, let window = delegate.window as? UIWindow {
            window.rootViewController = viewController
        }
    }
}

private extension ApplicationModuleImpl {
    
    func setupAppearance() {}
}
