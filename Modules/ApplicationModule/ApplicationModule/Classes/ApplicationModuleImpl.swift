import Foundation
import NNModule_swift
import SafariServices
import ModuleServices

extension Module.RegisterService {
    
    @objc static func applicationModule() {
        Module.register(service: ModuleApplicationService.self, used: ApplicationModuleImpl.self)
        Module.register(service: ModuleRouteService.self, used: ApplicationModuleImpl.self)
    }
}

class ApplicationModuleImpl: NSObject, ModuleApplicationService, ModuleRouteService {

    static var implPriority: Int { 100 }
    
    private var router: URLRouter = URLRouter()
    
    var routeParser: URLRouteParserType {
        set { router.routeParser = newValue }
        get { router.routeParser }
    }
    
    var window: UIWindow?
    
    required override init() {
        super.init()

        if let cls = NSClassFromString("TabBarController.TabBarController"),
           let tabBarType = cls as? UITabBarController.Type {
            Module.tabService.tabBarControllerType = tabBarType
        }
        
        router.routeParser.defaultScheme = "app"
        router.registerRoute(router.webLink) { url, navigator in
            guard let string = url.parameters["url"] as? String, let url = URL(string: string) else {
                return false
            }
            
            navigator.push(SFSafariViewController(url: url))
            return true
        }
        
        Module.service(of: LoginService.self).eventSet.registerTarget(self)
        
        let notifications: [LoginNotification] = [.didLoginSuccess, .didLogoutSuccess]
        let notificationImpl = Module.notificationeService
        notifications.forEach {
            notificationImpl.observe(name: $0.rawValue) { [weak self] _ in self?.reloadMainViewController() }.disposed(by: self)
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
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            let routes: [String: String] = ["b2page": "amodule/a3"]
//            self.updateRedirectRoutes(routes)
//        }
       
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
        if let scheme = url.scheme?.lowercased(), scheme == Module.routeService.routeParser.defaultScheme {
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
    
    func addLazyRegister(_ register: @escaping (URLRouterType) -> Void) {
        router.addLazyRegister(register)
    }
    
    func registerRoute(_ route: URLRouteConvertible, handleRouteFactory: @escaping HandleRouteFactory) {
        router.registerRoute(route, handleRouteFactory: handleRouteFactory)
    }
    
    func registerRoute(_ route: URLRouteConvertible, combiner: URLRouteCombine) {
        router.registerRoute(route, combiner: combiner)
    }
    
    func openRoute(_ route: URLRouteConvertible, parameters: [String : Any]) -> Bool {
        router.openRoute(route, parameters: parameters)
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
