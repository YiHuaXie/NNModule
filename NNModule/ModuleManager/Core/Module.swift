//
//  Module.swift
//  ModuleManager
//
//  Created by NeroXie on 2019/11/21.
//

import Foundation

public final class Module {
    
    private init() {}
    
    static var serviceCenter: ModuleServiceCenter { ModuleServiceCenter.shared }

    public static var routeService: ModuleRouteService { service(of: ModuleRouteService.self) }
    
    public static var applicationService: ModuleApplicationService { service(of: ModuleApplicationService.self) }
    
    public static var tabService: ModuleTabService { service(of: ModuleTabService.self) }
    
    public static var launchTaskService: ModuleLaunchTaskService { service(of: ModuleLaunchTaskService.self) }
    
    public static var notificationService: ModuleNotificationService { service(of: ModuleNotificationService.self) }
    
    public static var topViewController: UIViewController? { UIApplication.topViewController }
    
    /// Register services
    /// - Parameters:
    ///   - serviceType: The type of serivce
    ///   - implClass: The class that implements the service
    public static func register<Service>(service serviceType: Service.Type, used implClass: AnyClass) {
        serviceCenter.register(service: serviceType, used: implClass)
    }
    
    /// Get the instance of the service.
    /// Since the instance is lazy loaded, so pay attention to whether there is a service mutual reference in the constructor.
    /// - Parameter serviceType: The type of serivce
    public static func service<Service>(of serviceType: Service.Type) -> Service {
        serviceCenter.service(of: serviceType)!
    }
    
    /// Remove service
    /// - Parameter serviceType: The type of serivce
    public static func removeService<Service>(of serviceType: Service.Type) {
        serviceCenter.removeService(of: serviceType)
    }
    
    /// Get the register impl instance of class
    /// - Parameter implClass: The class that provides a service which conforms to protocol `ModuleRegisteredService`
    public static func registerImpl(of implClass: AnyClass) -> ModuleRegisteredService? {
        serviceCenter.registerImpl(of: implClass)
    }
    
//#if DEBUG
//    public static func serviceMapInfoPrettyPrinted() {
//        serviceCenter.mapInfoPrettyPrinted()
//    }
//#endif
    
    public final class RegisterService {}
    
    public final class Awake {}
}
