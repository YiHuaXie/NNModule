//
//  ModuleTabManager.swift
//  ModuleManager
//
//  Created by NeroXie on 2019/1/20.
//

import UIKit

public class ModuleTabServiceImpl: ModuleTabService {
    
    private var _tabBarController: UITabBarController?
    
    private var tabItemImpls: [RegisterTabItemService] = []
    
    public private(set) var tabBarItemMeta: [TabBarItemMeta] = []
    
    public var tabBarControllerType: UITabBarController.Type = TabBarController.self
    
    public var tabBarController: UITabBarController { _tabBarController ?? tabBarControllerType.init() }
    
    public required init() {}
    
    public func setupTabBarController(with tabBarController: UITabBarController) {
        _tabBarController = tabBarController
        
        tabItemImpls.forEach { impl in
            impl.setupTabBarController(tabBarController)
            tabBarItemMeta += impl.registerTabBarItems().map {
                var meta = $0;
                meta.impl = impl;
                return meta
            }
        }
        
        tabBarItemMeta = tabBarItemMeta.sorted(by: { $0.tabIndex < $1.tabIndex })
    }
    
    public func addRegister(_ register: RegisterTabItemService.Type) {
        // 
        if let impl = Module.registerImpl(of: register) as? RegisterTabItemService {
            tabItemImpls.append(impl)
        }
    }
    
    public func needReloadTabBarController() {
        tabBarItemMeta = []
        _tabBarController = nil
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

