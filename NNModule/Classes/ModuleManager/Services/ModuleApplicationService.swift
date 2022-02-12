//
//  ModuleAppService.swift
//  ModuleManager
//
//  Created by NeroXie on 2019/1/18.
//

import Foundation

/// Application Service
/// This service is used to implement the functions which in `UIApplicationDelegate`.
public protocol ModuleApplicationService: ModuleFunctionalService, UIApplicationDelegate {
    
    func reloadMainViewController()
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool
}


