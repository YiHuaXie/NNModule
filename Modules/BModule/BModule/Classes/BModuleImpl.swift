import NNModule_swift
import ModuleServices
import TabBarController
import ESTabBarController_swift
import BaseModule

extension Module.Awake {
    
    @objc static func bModuleAwake() {
        Module.tabService.addRegister(BModuleImpl.self)
        Module.launchTaskService.addRegister(ModuleLaunchTaskTest.self)
    }
}

class BModuleImpl: NSObject, RegisterTabItemService {
    
    func registerTabBarItems() -> [TabBarItemMeta] {
        let configImpl = Module.service(of: ModuleConfigService.self)
        guard let index = configImpl.tabBarItemIndex(for: "user") else { return [] }
            
        let bundle = resourceBundle(of: "BModule")
        let nav = UINavigationController(rootViewController: UserViewController())
        let image = UIImage(named: "tabbar_user_normal", in: bundle, compatibleWith: nil)
        let selectedImage = UIImage(named: "tabbar_user_normal", in: bundle, compatibleWith: nil)
        nav.tabBarItem = ESTabBarItem(NormalTabBarItemContentView(), title: "user", image: image, selectedImage: selectedImage)
        let meta = TabBarItemMeta(viewController: nav, tabIndex: index)
        
        return [meta]
    }
    
    override required init() {
        super.init()    
    }
}

