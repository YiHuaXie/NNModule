//
//  ModuleAppService.swift
//  ModuleManager
//
//  Created by NeroXie on 2019/1/18.
//

import Foundation

/// Application Service
/// This service is used to implement the functions which in `UIApplicationDelegate`.
@objc public protocol ModuleApplicationService: ModuleFunctionalService, UIApplicationDelegate {
    
    /// Invoke before calling class methods of Module.Awake and after calling class methods of Module.RegisterService.
    func applicationWillAwake()
    
    /// Reload the main view controller
    func reloadMainViewController()
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool
}
