//
//  ModuleConfigServiceImpl.swift
//  ApplicationModule
//
//  Created by NeroXie on 2022/11/20.
//

import Foundation
import NNModule_swift
import ModuleServices

class ModuleConfigServiceImpl: NSObject, ModuleConfigService {
    
    private(set) var appScheme: String = ""
    
    private(set) var tabBarControllerType: UITabBarController.Type = UITabBarController.self
    
    private(set) var tabBarItems = [String]()
    
    required override init() {
        super.init()
        
        // 从主工程配置文件中读取
        appScheme = "nero"
        tabBarItems = ["example", "house", "user"]
        if let cls = NSClassFromString("TabBarController.TabBarController"), let tabBarType = cls as? UITabBarController.Type {
            tabBarControllerType = tabBarType
        }
    }
}
