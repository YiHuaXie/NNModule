//
//  ModuleConfigService.swift
//  ModuleServices
//
//  Created by NeroXie on 2022/11/20.
//

import Foundation
import NNModule_swift

@objc public protocol ModuleConfigService: ModuleFunctionalService {
    
    var appScheme: String { get }
    
    var tabBarControllerType: UITabBarController.Type { get }
    
    var tabBarItems: [String] { get }
    
//    func tabBarItemIndex(for itemName: String) -> Int
}

extension ModuleConfigService {

    public func tabBarItemIndex(for itemName: String) -> Int? {
        tabBarItems.firstIndex { $0 == itemName }
    }
}

