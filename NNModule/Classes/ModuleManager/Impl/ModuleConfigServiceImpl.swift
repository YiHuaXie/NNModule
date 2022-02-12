//
//  ModuleConfigManager.swift
//  ModuleManager
//
//  Created by NeroXie on 2019/1/18.
//

import Foundation

public class ModuleConfigSeriveImpl: ModuleConfigService {
    
    public private(set) var applicationService: ModuleApplicationService.Type = ModuleApplicationServiceImpl.self
    
    public var tabBar: UITabBarController.Type?
    
    public required init() {
        let data: [String: Any] = loadModuleConfig()
        
        if let string = data["app_service"] as? String,
           let applicationService = NSClassFromString(string.implClassName) as? ModuleApplicationService.Type  {
            self.applicationService = applicationService
        }
        
        if let string = data["tab_bar_class"] as? String,
           let cls = NSClassFromString(string) {
            tabBar = cls as? UITabBarController.Type
        }
    }
}

fileprivate extension String {

    var implClassName: String { "\(self).\(self)Impl" }
}
