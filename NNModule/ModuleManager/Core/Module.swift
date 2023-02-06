//
//  Module.swift
//  ModuleManager
//
//  Created by NeroXie on 2019/11/21.
//

import Foundation

@objcMembers public final class Module: NSObject {
    
    private override init() {}
    
    @objc(ModuleRegisterService)
    /// A class to register functional servicies.
    /// Adds static methods with @objc tag in category, register services in these static methods.
    public final class RegisterService: NSObject {
        
        private override init() {}
    }
    
    @objc(ModuleAwake)
    /// A class to register registered servicies and other initialization operations.
    /// Adds static methods with @objc tag in category, do something in these static methods.
    public final class Awake: NSObject {
        
        private override init() {}
    }
}

public extension Module {
    
    fileprivate static var serviceCenter: ModuleServiceCenter { ModuleServiceCenter.shared }
    
    static var routeService: ModuleRouteService { service(of: ModuleRouteService.self) }
    
    static var applicationService: ModuleApplicationService { service(of: ModuleApplicationService.self) }
    
    static var tabService: ModuleTabService { service(of: ModuleTabService.self) }
    
    static var launchTaskService: ModuleLaunchTaskService { service(of: ModuleLaunchTaskService.self) }
    
    static var notificationService: ModuleNotificationService { service(of: ModuleNotificationService.self) }
    
    static var topViewController: UIViewController? { UIApplication.topViewController }
    
    /// Register services
    /// - Parameters:
    ///   - serviceType: The type of serivce
    ///   - implClass: The class that implements the service.
    static func register<Service>(service serviceType: Service.Type, used implClass: AnyClass) {
        serviceCenter.register(service: serviceType, used: implClass)
    }
    
    /// Get the instance of the service.
    /// Since the instance is lazy loaded, so pay attention to whether there is a service mutual reference in the constructor.
    /// - Parameter serviceType: The type of serivce.
    /// - Returns: The instance of serivce.
    static func service<Service>(of serviceType: Service.Type) -> Service {
        serviceCenter.service(of: serviceType)!
    }
    
    /// Remove service
    /// - Parameter serviceType: The type of serivce
    static func removeService<Service>(of serviceType: Service.Type) {
        serviceCenter.removeService(of: serviceType)
    }
    
    @objc(registerImplOfClass:)
    /// Get the register impl instance of class
    /// - Parameter implClass: The class that provides a service which conforms to protocol `ModuleRegisteredService`
    static func registerImpl(of implClass: AnyClass) -> ModuleRegisteredService? {
        serviceCenter.registerImpl(of: implClass)
    }
}

@available(swift, obsoleted: 3.0, message: "Only used in Objective-C")
public extension Module {
    
    @objc(registerServiceOfProtocol:usedImplClass:)
    /// Register services
    /// - Parameters:
    ///   - serviceType: The type of serivce
    ///   - implClass: The class that implements the service.
    static func register(service serviceProtocol: Protocol, used implClass: AnyClass) {
        serviceCenter.register(service: serviceProtocol, used: implClass)
    }
    
    @objc(serivceOfProtocol:)
    /// Get the instance of the service.
    /// Since the instance is lazy loaded, so pay attention to whether there is a service mutual reference in the constructor.
    /// - Parameter serviceType: The type of serivce.
    /// - Returns: The instance of serivce.
    static func service(of serviceProtocol: Protocol) -> Any {
        serviceCenter.service(of: serviceProtocol)!
    }
    
    @objc(removeSerivceOfProtocol:)
    /// Remove service
    /// - Parameter serviceType: The type of serivce
    static func removeService(of serviceProtocol: Protocol) {
        serviceCenter.removeService(of: serviceProtocol)
    }
}
