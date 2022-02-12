//
//  ModuleTabService.swift
//  ModuleManager
//
//  Created by NeroXie on 2019/1/20.
//

import UIKit

/// TabBar service.
public protocol ModuleTabService: ModuleFunctionalService {
    
    /// The instance of tabBar controller
    var tabBarController: UITabBarController { get }
    
    /// The meta of tabBar item
    var tabBarItemMeta: [TabBarItemMeta] { get }
    
    /// Setup tabBar controller
    /// - Parameter tabBarController: the instance of tabBarController
    func setupTabBarController(with tabBarController: UITabBarController)
    
    /// Add register of tabBar item
    func addRegister(_ register: RegisterTabItemService.Type)
}

public extension ModuleTabService {
    
    /// Get the instance of RegisterTabItemService corresponding to the viewController.
    /// - Parameters:
    ///   - tabBarController: The instance of current tabBar controller
    ///   - viewController: The specified ViewController
    /// - Returns: RegisterTabItemService
    func impl(in tabBarController: UITabBarController, of viewController: UIViewController) -> RegisterTabItemService? {
        guard let index = tabBarController.children.firstIndex(of: viewController) else {
            return nil
        }
        
        return tabBarItemMeta[index].impl
    }
}

/// Register tabBar item
public protocol RegisterTabItemService: ModuleRegisteredService, UITabBarControllerDelegate {
    
    /// Setup the tabBar controller when created
    func setupTabBarController(_ tabBarController: UITabBarController)
    
    /// Register tabBar items
    func registerTabBarItems() -> [TabBarItemMeta]
}

extension RegisterTabItemService {
    
    public func setupTabBarController(_ tabBarController: UITabBarController) {}
    
    public func registerTabBarItems() -> [TabBarItemMeta] { [] }
}


/// The meta that describe tabBar item.
public struct TabBarItemMeta {
    
    internal var impl: RegisterTabItemService?
    
    public var viewController: UIViewController
    
    public var tabIndex: Int
    
    public init(viewController: UIViewController, tabIndex: Int) {
        self.viewController = viewController
        self.tabIndex = tabIndex
    }
}
