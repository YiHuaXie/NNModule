//
//  ModuleConfigService.swift
//  ModuleManager
//
//  Created by NeroXie on 2019/1/18.
//

import Foundation

/// Services used to obtain components.
/// This service will read all components from the `config_module.json` of the main project.
public protocol ModuleConfigService: ModuleFunctionalService {
    
    /// A component that provice application service.
    var applicationService: ModuleApplicationService.Type { get }
    
    /// Custom tabBarController class
    var tabBar: UITabBarController.Type? { get }
}

extension ModuleConfigService {
    
    /// Load the configuration of all components.
    public func loadModuleConfig() -> [String: Any] {
        guard let path = Bundle.main.path(forResource: "module_config.json", ofType: nil) else {
            assertionFailure("Please configure the `module_config.json` under the main project.")
            return [:]
        }
        
        let url = URL(fileURLWithPath: path)
        
        do {
            let data = try Data(contentsOf: url)
            guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else {
                assertionFailure("The content of `module_config.json` must be a dictionary.")
                return [:]
            }
            return dictionary
        } catch {
            assertionFailure(error.localizedDescription)
            return [:]
        }
    }
}
