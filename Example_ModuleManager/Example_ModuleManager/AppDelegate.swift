//
//  AppDelegate.swift
//  Example_ModuleManager
//
//  Created by NeroXie on 2021/8/16.
//

import UIKit
import NNModule

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    override init() {
        super.init()
        // Ensure that `ModuleManager.shared` is created first
        _ = ModuleManager.shared
    }
    
    func application(
        _ application: UIApplication,
        willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        ModuleManager.shared.application(application, willFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        ModuleManager.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override func forwardingTarget(for aSelector: Selector!) -> Any? { Module.applicationService }
    
    override func responds(to aSelector: Selector!) -> Bool {
        super.responds(to: aSelector) || Module.applicationService.responds(to: aSelector)
    }
}
