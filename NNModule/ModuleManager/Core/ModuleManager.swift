//
//  ModuleManager.swift
//  ModuleManager
//
//  Created by NeroXie on 2019/1/18.
//

import Foundation
import UIKit

public final class ModuleManager {
    
    public static let shared = ModuleManager()
    
    private var registerServices = [Method]()
    
    private var awakes = [Method]()
    
    private init() {
        // register services
        Module.register(service: ModuleRouteService.self, used: URLRouter.self)
        Module.register(service: ModuleTabService.self, used: ModuleTabServiceImpl.self)
        Module.register(service: ModuleLaunchTaskService.self, used: ModuleLaunchTaskServiceImpl.self)
        Module.register(service: ModuleEventBusService.self, used: EventBus.self)
        Module.register(service: ModuleNotificationService.self, used: ModuleNotificationServiceImpl.self)
        Module.register(service: ModuleApplicationService.self, used: ModuleApplicationServiceImpl.self)
        
        // register more services
        loadAllMethods(from: Module.RegisterService.self)
    }
    
    public func application(
        _ application: UIApplication,
        willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?
    ) -> Bool {
        // load application service early
        let applicationImpl = Module.applicationService
        // wake up all modules to register
        loadAllMethods(from: Module.Awake.self)
        // execute launch task
        Module.launchTaskService.execute()
        
        return applicationImpl.application?(application, willFinishLaunchingWithOptions: launchOptions) ?? true
    }
    
    public func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        loadWindowIfNeed()
        return Module.applicationService.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}

private extension ModuleManager {
    
    func loadWindowIfNeed() {
        guard UIApplication.shared.keyWindow == nil else { return }
        
        // forcibly load the window
        let sel = NSSelectorFromString("setWindow:")
        var window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = .white
        if let win = Module.applicationService.window as? UIWindow { window = win }
        Module.applicationService.perform(sel, with: window)
        if let delegate = UIApplication.shared.delegate, delegate.responds(to: sel) {
            delegate.perform(sel, with: window)
        }
        
        window.makeKeyAndVisible()
    }
    
    func loadAllMethods(from aClass: AnyClass) {
        guard let metaClass: AnyClass = object_getClass(aClass) else { return }
        
        var count: UInt32 = 0
        guard let methodList = class_copyMethodList(metaClass, &count) else { return }
        
        let handle = dlopen(nil, RTLD_LAZY)
        let methodInvoke = dlsym(handle, "method_invoke")
        
        for i in 0..<Int(count) {
            let method = methodList[i]
            unsafeBitCast(methodInvoke, to:(@convention(c)(Any, Method)->Void).self)(metaClass, method)
        }
        
        dlclose(handle)
        free(methodList)
    }
}
















