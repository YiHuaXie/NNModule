import NNModule_swift
import ModuleServices
import TabBarController
import ESTabBarController_swift
import BaseModule
import SafariServices

extension Module.RegisterService {
    
    @objc static func aModuleRegisterService() {
        Module.register(service: HouseService.self, used: HouseManager.self)
    }
}

extension Module.Awake {
    
    @objc static func aModuleAwake() {
        let subRouter = AModuleImpl.router
        Module.routeService.registerRoutes(["house", subRouter.webLink], used: subRouter)
        Module.tabService.addRegister(AModuleImpl.self)
        Module.launchTaskService.addRegister(ModuleLaunchTaskTest.self)
    }
}

class AModuleImpl: NSObject, RegisterTabItemService {

    fileprivate(set) static var router: URLRouter = {
        let router = URLRouter(with: Module.routeService)
        router.delayedRegisterRoute(router.webLink) { url, navigator in
            guard let string = url.parameters["url"] as? String, let url = URL(string: string) else { return false }
            
            navigator.push(SFSafariViewController(url: url))
            return true
        }
        
        router.delayedRegisterRoute("house") { routeUrl, navigator in
            switch routeUrl.path {
            case "/main":
                let vc = HouseListViewController()
                vc.modalPresentationStyle = .fullScreen
                navigator.present(vc, wrap: UINavigationController.self, animated: true)
                return true
            case "/add":
                navigator.push(AddHouseViewController())
                return true
            default: return false
            }
        }
        
        return router
    }()
    
    override required init() {
        super.init()
    }
    
    func setupTabBarController(_ tabBarController: UITabBarController) {
        if let tabBarController = tabBarController as? TabBarController {
            tabBarController.shouldHijackHandler = { _ ,_ , index in index == 1 }
            tabBarController.didHijackHandler = { _, _, _ in AModuleImpl.router.openRoute("house/main") }
        }
    }
    
    func registerTabBarItems() -> [TabBarItemMeta] {
        let bundle = resourceBundle(of: "AModule")
        var metaList = [TabBarItemMeta]()
        let configImpl = Module.service(of: ModuleConfigService.self)
        
        if let index = configImpl.tabBarItemIndex(for: "example") {
            let nav = UINavigationController(rootViewController: ExampleViewController())
            let image = UIImage(named: "tabbar_houses_normal", in: bundle, compatibleWith: nil)
            let selectedImage = UIImage(named: "tabbar_houses_normal", in: bundle, compatibleWith: nil)
            nav.tabBarItem = ESTabBarItem(NormalTabBarItemContentView(), title: "example", image: image, selectedImage: selectedImage)
            let meta = TabBarItemMeta(viewController: nav, tabIndex: index)
            metaList.append(meta)
        }
        
        if let index = configImpl.tabBarItemIndex(for: "house") {
            let vc = UIViewController()
            let image = UIImage(named: "tabbar_add", in: bundle, compatibleWith: nil)
            vc.tabBarItem = ESTabBarItem(LargeTabBarItemContentView(), title: "house", image: image)
            let meta = TabBarItemMeta(viewController: vc, tabIndex: index)
            metaList.append(meta)
        }

        return metaList
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        print("\(type(of: self))：\(#function)")
        
        return true
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print("\(type(of: self))：\(#function)")
    }
}


