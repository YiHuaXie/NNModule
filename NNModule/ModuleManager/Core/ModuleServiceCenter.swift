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
    
    private var serviceTypeMap: [ObjectIdentifier: ModuleFunctionalService.Type] = [:]
    
    private var implInstanceMap: [ObjectIdentifier: ModuleBasicService] = [:]
    
#if DEBUG
    private var implClassList: [String] = []
#endif
    
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
        guard let oldImplClass = serviceTypeMap[key] else {
            serviceTypeMap[key] = newImplClass
            return
        }
        
        if oldImplClass.implPriority < newImplClass.implPriority {
            serviceTypeMap[key] = newImplClass
        }
    }
    
    /// Get the instance of the service.
    /// Since the instance is lazy loaded, so pay attention to whether there is a service mutual reference in the constructor.
    /// - Parameter serviceType: The type of serivce
    func service<Service>(of serviceType: Service.Type) -> Service? {
        let serviceTypeKey = ObjectIdentifier(serviceType)
        guard let implClass = serviceTypeMap[serviceTypeKey] else {
            assertionFailure("the impl class of \(serviceType) is nil, please register it first")
            return nil
        }
        
        let implKey = ObjectIdentifier(implClass)
        if let impl = implInstanceMap[implKey] as? Service { return impl }
        
#if DEBUG
        let className = "\(implClass)"
        guard !implClassList.contains(className) else {
            var string = "Found loop when creating service impl: "
            implClassList.forEach { string += "\($0) -> " }
            string += className
            assertionFailure(string)
            
            return nil
        }
        
        implClassList.append(className)
#endif
        let newImpl = implClass.implInstance
#if DEBUG
        implClassList.removeAll()
#endif
        implInstanceMap[implKey] = newImpl
        
        return newImpl as? Service
    }
    
    /// Remove service
    /// - Parameter serviceType: The type of serivce
    func removeService<Service>(of serviceType: Service.Type) {
        let key = ObjectIdentifier(serviceType)
        serviceTypeMap.removeValue(forKey: key)
        implInstanceMap.removeValue(forKey: key)
    }
    
    /// Get the register impl instance of class
    /// - Parameter implClass: The class that provides a service which conform to protocol `ModuleRegisteredService`
    func registerImpl(of implClass: AnyClass) -> ModuleRegisteredService? {
        guard let registerImplClass = implClass as? ModuleRegisteredService.Type else { return nil }
        
        let key = ObjectIdentifier(registerImplClass)
        let keepaliveRegiteredImpl = registerImplClass.keepaliveRegiteredImpl
        if keepaliveRegiteredImpl, let impl = implInstanceMap[key] {
            return impl as? ModuleRegisteredService
        }
        
        let newImpl = registerImplClass.implInstance
        // save impl of this class if it is possible
        if keepaliveRegiteredImpl { implInstanceMap[key] = newImpl }
        
        return newImpl
    }
}


