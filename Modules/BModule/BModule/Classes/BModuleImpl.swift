import NNModule
import ModuleServices
import TabBarController
import ESTabBarController_swift
import BaseModule

extension Module.Awake {
    
    @objc static func bModuleAwake() {
        Module.tabService.addRegister(BModuleImpl.self)
        
        Module.launchTaskService.addRegister(HomeManager.self)
        
        Module.routeService.registerRoute("B2Page") { url, navigator in
            print(url.parameters)
            navigator.present(B2ViewController())
            
            return true
        }
    }
}

class BModuleImpl: NSObject, RegisterTabItemService {
    
    func registerTabBarItems() -> [TabBarItemMeta] {
        let bundle = resourceBundle(of: "BModule")
        let vc = B1ViewController()
        vc.modalPresentationStyle = .fullScreen
        let nav = UINavigationController(rootViewController: vc)
        let image = UIImage(named: "tabbar_user_normal", in: bundle, compatibleWith: nil)
        let selectedImage = UIImage(named: "tabbar_user_normal", in: bundle, compatibleWith: nil)
        nav.tabBarItem = ESTabBarItem(NormalTabBarItemContentView(), title: "user", image: image, selectedImage: selectedImage)
        let meta = TabBarItemMeta(viewController: nav, tabIndex: 2)
        
        return [meta]
    }
    
    override required init() {
        super.init()
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        print("\(type(of: self))：\(#function)")
        
        return true
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print("\(type(of: self))：\(#function)")
    }
}

final class HomeManager: RegisterLaunchTaskService {
    
    required init() {}
    
    func startTask() {
        let classStr = NSStringFromClass(type(of: self))
        print("\(classStr) start task")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            print("\(classStr) finish task")
        }
    }
}
