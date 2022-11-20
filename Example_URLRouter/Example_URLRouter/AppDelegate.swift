//
//  AppDelegate.swift
//  Example_URLRouter
//
//  Created by NeroXie on 2021/8/15.
//

import UIKit
import NNModule_swift
import SafariServices

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Override point for customization after application launch.
        RouteUtils.setup()
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        window.backgroundColor = .white
        window.rootViewController = UINavigationController(rootViewController: ViewController())
        window.makeKeyAndVisible()
        
        return true
    }
    
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        // Support Deeplink
        if URLRouter.default.openRoute(url) { return true }
        
        return false
    }
}




