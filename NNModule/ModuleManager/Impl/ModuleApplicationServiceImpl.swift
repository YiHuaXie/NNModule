//
//  ModuleApplicationServiceImpl.swift
//  ModuleManager
//
//  Created by NeroXie on 2019/1/18.
//

import Foundation

class ModuleApplicationServiceImpl: NSObject, ModuleApplicationService {
    
    override required init() { super.init() }
    
    func applicationWillAwake() {}
    
    func reloadMainViewController() {}
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?
    ) -> Bool {
        true
    }
}
