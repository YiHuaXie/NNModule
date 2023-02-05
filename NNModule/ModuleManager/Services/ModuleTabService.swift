//
//  ModuleTabService.swift
//  ModuleManager
//
//  Created by NeroXie on 2019/1/20.
//

import UIKit

/// TabBar service.
@objc public protocol ModuleTabService: ModuleFunctionalService {
    
    /// The Type of tabBar controller
    var tabBarControllerType: UITabBarController.Type { set get }
    
    /// The instance of tabBar controller
    var tabBarController: UITabBarController { get }
    
    /// The meta of tabBar item
    var tabBarItemMeta: [TabBarItemMeta] { get }
    
    /// Setup tabBar controller
    /// - Parameter tabBarController: the instance of tabBarController
    func setupTabBarController(with tabBarController: UITabBarController)
    
    /// Add register of tabBar item
    func addRegister(_ register: RegisterTabItemService.Type)
    
    /// Need to reload the tabBar.
    func needReloadTabBarController()
    
    /// Get the instance of RegisterTabItemService corresponding to the viewController.
    /// - Parameters:
    ///   - tabBarController: The instance of current tabBar controller
    ///   - viewController: The specified ViewController
    /// - Returns: RegisterTabItemService
    func impl(in tabBarController: UITabBarController, of viewController: UIViewController) -> RegisterTabItemService?
}

/// Register tabBar item
@objc public protocol RegisterTabItemService: ModuleRegisteredService, UITabBarControllerDelegate {
    
    /// Setup the tabBar controller when created
    @objc optional func setupTabBarController(_ tabBarController: UITabBarController)
    
    /// Register tabBar items
    @objc optional func registerTabBarItems() -> [TabBarItemMeta]
}

/// The meta that describe tabBar item.
@objcMembers public class TabBarItemMeta: NSObject {
    
    internal var impl: RegisterTabItemService?
    
    public var viewController: UIViewController
    
    public var tabIndex: Int
    
    public init(viewController: UIViewController, tabIndex: Int) {
        self.viewController = viewController
        self.tabIndex = tabIndex
        
        super.init()
    }
}
