import NNModule_swift
import ModuleServices
import TabBarController
import ESTabBarController_swift
import BaseModule

extension Module.RegisterService {
    
    @objc static func aModuleRegisterService() {
        Module.register(service: HomeService.self, used: HomeManager.self)
    }
}

extension Module.Awake {
    
    @objc static func aModuleAwake() {
        Module.tabService.addRegister(AModuleImpl.self)
        Module.launchTaskService.addRegister(HomeManager.self)
        Module.routeService.registerRoute("amodule", combiner: AModuleImpl.router)
    }
}

class AModuleImpl: NSObject, RegisterTabItemService {

    fileprivate static var router: URLRouter {
        let router = URLRouter()
        debugPrint("default scheme: \(Module.routeService.routeParser.defaultScheme)")
        router.routeParser.defaultScheme = Module.routeService.routeParser.defaultScheme
        router.lazyRegister = {
            $0.registerRoute("amodule/a2") { url, navigator in
                print(url.parameters)
                navigator.push(A2ViewController())
                
                return true
            }
            
            $0.registerRoute("amodule/a3") { url, navigator in
                let vc = A3ViewController()
                navigator.present(vc, wrap: UINavigationController.self)
                return true
            }
        }
        
        return router
    }
    
    override required init() {
        super.init()
    }
    
    func setupTabBarController(_ tabBarController: UITabBarController) {
        if let tabBarController = tabBarController as? TabBarController {
            tabBarController.shouldHijackHandler = { _ ,_ , index in index == 1 }
            tabBarController.didHijackHandler = { _, _, _ in Module.routeService.openRoute("amodule/a3") }
        }
    }
    
    func registerTabBarItems() -> [TabBarItemMeta] {
        let bundle = resourceBundle(of: "AModule")
        
        let vc1 = A1ViewController()
        vc1.modalPresentationStyle = .fullScreen
        let nav1 = UINavigationController(rootViewController: vc1)
        let image1 = UIImage(named: "tabbar_houses_normal", in: bundle, compatibleWith: nil)
        let selectedImage1 = UIImage(named: "tabbar_houses_normal", in: bundle, compatibleWith: nil)
        nav1.tabBarItem = ESTabBarItem(NormalTabBarItemContentView(), title: "home", image: image1, selectedImage: selectedImage1)
        let meta1 = TabBarItemMeta(viewController: nav1, tabIndex: 0)
        
        let vc2 = UIViewController()
        vc2.modalPresentationStyle = .fullScreen
        let nav2 = UINavigationController(rootViewController: vc2)
        let image2 = UIImage(named: "tabbar_add", in: bundle, compatibleWith: nil)
        nav2.tabBarItem = ESTabBarItem(LargeTabBarItemContentView(), title: "add", image: image2)
        let meta2 = TabBarItemMeta(viewController: nav2, tabIndex: 1)
        return [meta1, meta2]
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        print("\(type(of: self))：\(#function)")
        
        return true
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print("\(type(of: self))：\(#function)")
    }
}
