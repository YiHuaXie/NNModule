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
    
    static var routeService: ModuleRouteService { serviceImpl(of: ModuleRouteService.self) }
    
    static var applicationService: ModuleApplicationService { serviceImpl(of: ModuleApplicationService.self) }
    
    static var tabService: ModuleTabService { serviceImpl(of: ModuleTabService.self) }
    
    static var launchTaskService: ModuleLaunchTaskService { serviceImpl(of: ModuleLaunchTaskService.self) }
    
    static var notificationService: ModuleNotificationService { serviceImpl(of: ModuleNotificationService.self) }
    
    static var topViewController: UIViewController? { UIApplication.topViewController }
    
    /// Register services
    /// - Parameters:
    ///   - serviceType: The type of serivce
    ///   - implClass: The class that implements the service.
    static func register<Service>(service serviceType: Service.Type, used implClass: AnyClass) {
        guard implClass is Service else {
            assertionFailure("\(implClass) must conforms to service \(serviceType)")
            return
        }
        
        serviceCenter.registerService(of: ServiceIdentifier(serviceType), used: implClass)
    }
    
    @available(*, deprecated, renamed: "serviceImpl(of:)")
    /// Get the instance of the service.
    /// Since the instance is lazy loaded, so pay attention to whether there is a service mutual reference in the constructor.
    /// - Parameter serviceType: The type of serivce.
    /// - Returns: The instance of serivce.
    static func service<Service>(of serviceType: Service.Type) -> Service {
        serviceCenter.serviceImpl(of: ServiceIdentifier(serviceType)) as! Service
    }
    
    /// Get the instance of the service.
    /// If the service is customized, the instance type is `ServiceImplProxy`, otherwise it returns native instance.
    /// - Parameter serviceType: The type of serivce.
    /// - Returns: The instance of serivce.
    static func serviceImpl<Service>(of serviceType: Service.Type) -> Service {
        serviceCenter.serviceImpl(of: ServiceIdentifier(serviceType)) as! Service
    }
    
    /// Get the native instance of the service.
    /// Since the instance is lazy loaded, so pay attention to whether there is a service mutual reference in the constructor.
    /// - Parameter serviceType: The type of serivce.
    /// - Returns: The instance of serivce.
    static func serviceNativeImpl<Service>(of serviceType: Service.Type) -> Service {
        serviceCenter.serviceNativeImpl(of: ServiceIdentifier(serviceType)) as! Service
    }
    
    @objc(registerImplOfClass:)
    /// Get the register impl instance of class
    /// - Parameter implClass: The class that provides a service which conforms to protocol `ModuleRegisteredService`
    static func registerImpl(of implClass: AnyClass) -> ModuleRegisteredService? {
        serviceCenter.registerImpl(of: implClass)
    }
    
    /// Remove service
    /// - Parameter serviceType: The type of serivce
    static func removeService<Service>(of serviceType: Service.Type) {
        serviceCenter.removeService(of: ServiceIdentifier(serviceType))
    }
    
    /// Bridge a instance method in the service.
    /// - Parameters:
    ///   - method: The instance method in the service.
    ///   - serviceType: The type of serivce.
    ///   - aClass: The class that implements the bridged instance method.
    static func bridge<Service>(method: Selector, of serviceType: Service.Type, used aClass: AnyClass) {
        serviceCenter.bridge(method: method, isClassMethod: false, of: ServiceIdentifier(serviceType), used: aClass)
    }
    
    /// Bridge a class method in the service.
    /// - Parameters:
    ///   - classMethod: The class method in the service.
    ///   - serviceType: The type of serivce.
    ///   - aClass: The class that implements the bridged class method.
    static func bridge<Service>(classMethod: Selector, of serviceType: Service.Type, used aClass: AnyClass) {
        serviceCenter.bridge(method: classMethod, isClassMethod: true, of: ServiceIdentifier(serviceType), used: aClass)
    }
    
    static func serviceInfoPrettyPrinted() {
        serviceCenter.serviceInfoPrettyPrinted()
    }
}

@available(swift, obsoleted: 3.0, message: "Only used in Objective-C")
public extension Module {
    
    @objc(registerServiceOfProtocol:usedImplClass:)
    /// Register services
    /// - Parameters:
    ///   - serviceProtocol: The type of serivce
    ///   - implClass: The class that implements the service.
    static func register(service serviceProtocol: Protocol, used implClass: AnyClass) {
        guard implClass.conforms(to: serviceProtocol) else {
            assertionFailure("\(implClass) must conforms to service \(serviceProtocol)")
            return
        }
        
        serviceCenter.registerService(of: ServiceIdentifier(serviceProtocol), used: implClass)
    }
    
    @available(*, deprecated, renamed: "serviceImpl(of:)")
    @objc(serivceOfProtocol:)
    /// Get the instance of the service.
    /// Since the instance is lazy loaded, so pay attention to whether there is a service mutual reference in the constructor.
    /// - Parameter serviceProtocol: The type of serivce.
    /// - Returns: The instance of serivce.
    static func service(of serviceProtocol: Protocol) -> Any {
        serviceCenter.serviceImpl(of: ServiceIdentifier(serviceProtocol))!
    }
    
    @objc(serivceImplOfProtocol:)
    /// Get the instance of the service.
    /// If the service is customized, the instance type is `ServiceImplProxy`, otherwise it returns native instance.
    /// - Parameter serviceProtocol: The type of serivce.
    /// - Returns: The instance of serivce.
    static func serviceImpl(of serviceProtocol: Protocol) -> Any {
        serviceCenter.serviceImpl(of: ServiceIdentifier(serviceProtocol))!
    }
    
    @objc(serivceNativeImplOfProtocol:)
    /// Get the native instance of the service.
    /// Since the instance is lazy loaded, so pay attention to whether there is a service mutual reference in the constructor.
    /// - Parameter serviceProtocol: The type of serivce.
    /// - Returns: The instance of serivce.
    static func serviceNativeImpl(of serviceProtocol: Protocol) -> Any {
        serviceCenter.serviceNativeImpl(of: ServiceIdentifier(serviceProtocol))!
    }
    
    @objc(removeSerivceOfProtocol:)
    /// Remove service
    /// - Parameter serviceProtocol: The type of serivce
    static func removeService(of serviceProtocol: Protocol) {
        serviceCenter.removeService(of: ServiceIdentifier(serviceProtocol))
    }
    
    @objc(bridgeMethod:ofServiceProtocol:usedClass:)
    /// Bridge a instance method in the service.
    /// - Parameters:
    ///   - method: The instance method in the service.
    ///   - serviceProtocol: The type of serivce.
    ///   - aClass: The class that implements the bridged instance method.
    static func bridge(method: Selector, of serviceProtocol: Protocol, used aClass: AnyClass) {
        serviceCenter.bridge(method: method, isClassMethod: false, of: ServiceIdentifier(serviceProtocol), used: aClass)
    }
    
    @objc(bridgeClassMethod:ofServiceProtocol:usedClass:)
    /// Bridge a class method in the service.
    /// - Parameters:
    ///   - classMethod: The class method in the service.
    ///   - serviceProtocol: The type of serivce.
    ///   - aClass: The class that implements the bridged class method.
    static func bridge(classMethod: Selector, of serviceProtocol: Protocol, used aClass: AnyClass) {
        serviceCenter.bridge(method: classMethod, isClassMethod: true, of: ServiceIdentifier(serviceProtocol), used: aClass)
    }
}
