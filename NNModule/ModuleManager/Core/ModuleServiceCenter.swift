//
//  ModuleServiceManager.swift
//  ModuleManager
//
//  Created by NeroXie on 2019/1/18.
//

import Foundation

/// The manager of service's map
final class ModuleServiceCenter {
    
    static let shared = ModuleServiceCenter()
    
    private var serviceImplClassMap: [ObjectIdentifier: ModuleFunctionalService.Type] = [:]
    
    private var implMap: [ObjectIdentifier: ModuleBasicService] = [:]

    private init() {}
    
    /// Register services
    /// - Parameters:
    ///   - serviceType: The type of serivce
    ///   - implClass: The class that implements the service
    func register<Service>(service serviceType: Service.Type, used implClass: AnyClass) {
        guard implClass is Service else {
            assertionFailure("\(implClass) must conforms to service \(serviceType)")
            return
        }
        
        guard let newImplClass = implClass as? ModuleFunctionalService.Type else {
            assertionFailure("\(serviceType) must conforms to service `ModuleFunctionalService`")
            return
        }
        
        let key = ObjectIdentifier(serviceType)
        guard let oldImplClass = serviceImplClassMap[key] else {
            serviceImplClassMap[key] = newImplClass
            return
        }
        
        if oldImplClass.implPriority < newImplClass.implPriority {
            serviceImplClassMap[key] = newImplClass
        }
    }
    
    /// Get the instance of the service.
    /// Since the instance is lazy loaded, so pay attention to whether there is a service mutual reference in the constructor.
    /// - Parameter serviceType: The type of serivce
    func service<Service>(of serviceType: Service.Type) -> Service {
        let key = ObjectIdentifier(serviceType)
        let basicImpl = implMap[key]
        if let impl = basicImpl as? Service { return impl }
        
        guard let implClass = serviceImplClassMap[key] else {
            assertionFailure("the impl of \(serviceType) is nil, please register the service first")
            return basicImpl as! Service
        }
        
        let impl = implClass.implInstance
        implMap[key] = impl
        
        return impl as! Service
    }
    
    /// Remove service
    /// - Parameter serviceType: The type of serivce
    func removeService<Service>(of serviceType: Service.Type) {
        let key = ObjectIdentifier(serviceType)
        serviceImplClassMap.removeValue(forKey: key)
        implMap.removeValue(forKey: key)
    }
    
    /// Get the register impl instance of class
    /// - Parameter implClass: The class that provides a service which conform to protocol `ModuleRegisteredService`
    func registerImpl(of implClass: AnyClass) -> ModuleRegisteredService? {
        guard let registerImplClass = implClass as? ModuleRegisteredService.Type else { return nil }

        let key = ObjectIdentifier(registerImplClass)
        let keepaliveRegiteredImpl = registerImplClass.keepaliveRegiteredImpl
        if keepaliveRegiteredImpl, let impl = implMap[key] { return impl as? ModuleRegisteredService }
        
        let newImpl = registerImplClass.implInstance
        // save impl of this class if it is possible
        if keepaliveRegiteredImpl { implMap[key] = newImpl }

        return newImpl
    }
}


