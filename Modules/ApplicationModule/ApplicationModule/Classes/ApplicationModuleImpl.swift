import Foundation
import NNModule_swift
import ModuleServices
import BaseModule
import ConfigModule

extension Module.RegisterService {
    
    @objc static func applicationModule() {
        Module.register(service: ModuleApplicationService.self, used: ApplicationModuleImpl.self)
        Module.register(service: ModuleRouteService.self, used: Router.self)
    }
}

class ApplicationModuleImpl: NSObject, ModuleApplicationService {
    
    static var implPriority: Int { 100 }
        
    var window: UIWindow?
    
    required override init() { super.init() }
    
    func applicationWillAwake() {
        let config = Module.service(of: ModuleConfigService.self)
        Module.tabService.tabBarControllerType = config.tabBarControllerType
    }
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?
    ) -> Bool {
        requestRedirectRoutes()
        setupAppearance()
        addNotification()
        reloadMainViewController()
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("\(type(of: self)): \(#function)")
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("\(type(of: self)): \(#function)")
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if let scheme = url.scheme?.lowercased(), scheme == Module.routeService.routeParser.defaultScheme {
            var newOptions = [String: Any]()
            options.forEach { newOptions[$0.rawValue] = $1 }
            
            return Module.routeService.openRoute(url.absoluteString, parameters: newOptions)
        }
        
        return false
    }
    
    func reloadMainViewController() {
        let loginImpl = Module.service(of: LoginService.self)
        if loginImpl.isLogin {
            MockServer.shared.reset()
            Module.tabService.needReloadTabBarController()
        }
        let viewController: UIViewController = loginImpl.isLogin ? Module.tabService.tabBarController : loginImpl.loginMain
        window?.rootViewController = viewController
    }
    
    private func addNotification() {
        let notificationImpl = Module.notificationService
        notificationImpl.addObserver(forName: .didLogoutSuccess) { [weak self] _ in
            self?.reloadMainViewController()
        }.disposed(by: self)
        
        notificationImpl.addObserver(forName: .didLoginSuccess) { [weak self] _ in
            self?.reloadMainViewController()
        }.disposed(by: self)
    }
    
    private func requestRedirectRoutes() {
        MockServer.shared.getRedirectRoutes {
            Module.routeService.routeRedirector.resetRedirectRoutes($0)
        }
    }
    
    private func setupAppearance() {}
}
