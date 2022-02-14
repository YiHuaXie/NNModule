//
//  Module.swift
//  ModuleManager
//
//  Created by NeroXie on 2019/11/21.
//

import Foundation

public final class Module {
    
    private init() {}
    
    static var serviceCenter: ModuleServiceCenter {
        ModuleServiceCenter.shared
    }

//    public static var configService: ModuleConfigService {
//        serviceCenter.service(of: ModuleConfigService.self)
//    }
    
    public static var routeService: ModuleRouteService {
        serviceCenter.service(of: ModuleRouteService.self)
    }
    
    public static var applicationService: ModuleApplicationService {
        serviceCenter.service(of: ModuleApplicationService.self)
    }
    
    public static var tabService: ModuleTabService {
        serviceCenter.service(of: ModuleTabService.self)
    }
    
    public static var launchTaskService: ModuleLaunchTaskService {
        serviceCenter.service(of: ModuleLaunchTaskService.self)
    }
    
    public static var noticeService: ModuleNoticeService {
        serviceCenter.service(of: ModuleNoticeService.self)
    }
    
    public static var topViewController: UIViewController? {
        Navigator.default.topViewController
    }
    
    public static func register<Service>(service serviceType: Service.Type, used implClass: AnyClass) {
        serviceCenter.register(service: serviceType, used: implClass)
    }
    
    public static func service<Service>(of serviceType: Service.Type) -> Service {
        serviceCenter.service(of: serviceType)
    }
    
    public static func removeService<Service>(of serviceType: Service.Type) {
        serviceCenter.removeService(of: serviceType)
    }
    
    public static func registerImpl(of implClass: AnyClass) -> ModuleRegisteredService? {
        serviceCenter.registerImpl(of: implClass)
    }
    
    public final class RegisterService {}
    
    public final class Awake {}
}
