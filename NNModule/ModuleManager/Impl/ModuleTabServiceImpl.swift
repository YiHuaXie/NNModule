//
//  ModuleTabManager.swift
//  ModuleManager
//
//  Created by NeroXie on 2019/1/20.
//

import UIKit

class ModuleTabServiceImpl: NSObject, ModuleTabService {
    
    private var _tabBarController: UITabBarController?
    
    private var tabItemImpls: [RegisterTabItemService] = []
    
    private(set) var tabBarItemMeta: [TabBarItemMeta] = []
    
    var tabBarControllerType: UITabBarController.Type = TabBarController.self
    
    var tabBarController: UITabBarController { _tabBarController ?? tabBarControllerType.init() }
    
    required override init() { super.init() }
    
    func setupTabBarController(with tabBarController: UITabBarController) {
        _tabBarController = tabBarController
        
        tabItemImpls.forEach { impl in
            impl.setupTabBarController?(tabBarController)
            tabBarItemMeta += (impl.registerTabBarItems?() ?? []).map { $0.impl = impl; return $0 }
        }
        
        tabBarItemMeta = tabBarItemMeta.sorted(by: { $0.tabIndex < $1.tabIndex })
    }
    
    func addRegister(_ register: RegisterTabItemService.Type) {
        guard let impl = Module.registerImpl(of: register) as? RegisterTabItemService else { return }
        
        tabItemImpls.append(impl)
    }
    
    func needReloadTabBarController() {
        tabBarItemMeta = []
        _tabBarController = nil
    }
    
    func impl(in tabBarController: UITabBarController, of viewController: UIViewController) -> RegisterTabItemService? {
        guard let index = tabBarController.children.firstIndex(of: viewController) else { return nil }
        
        return tabBarItemMeta[index].impl
    }
}

fileprivate class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        Module.tabService.setupTabBarController(with: self)
        viewControllers = Module.tabService.tabBarItemMeta.map {  $0.viewController }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let impl = Module.tabService.impl(in: tabBarController, of: viewController)
        return impl?.tabBarController?(tabBarController, shouldSelect: viewController) ?? true
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let impl = Module.tabService.impl(in: tabBarController, of: viewController)
        impl?.tabBarController?(tabBarController, didSelect: viewController)
    }
}

