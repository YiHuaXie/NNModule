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
    
    private var serviceTypeMap: [String: ModuleFunctionalService.Type] = [:]
    
    private var implInstanceMap: [ObjectIdentifier: ModuleBasicService] = [:]
    
#if DEBUG
    private var implClassList: [String] = []
#endif
    
    private init() {}
    
    func register<Service>(service serviceType: Service.Type, used implClass: AnyClass) {
        guard implClass is Service else {
            assertionFailure("\(implClass) must conforms to service \(serviceType)")
            return
        }
        
        register(service: SerivceName.value(of: serviceType), used: implClass)
    }
    
    func register(service serviceProtocol: Protocol, used implClass: AnyClass) {
        guard implClass.conforms(to: serviceProtocol) else {
            assertionFailure("\(implClass) must conforms to service \(serviceProtocol)")
            return
        }
        
        register(service: SerivceName.value(of: serviceProtocol), used: implClass)
    }
    
    func service<Service>(of serviceType: Service.Type) -> Service? {
        let serviceTypeName = SerivceName.value(of: serviceType)
        let impl: Service? = service(of: serviceTypeName)
        return impl
    }
    
    func service(of serviceProtocol: Protocol) -> ModuleFunctionalService? {
        let serviceTypeName = SerivceName.value(of: serviceProtocol)
        let impl: ModuleFunctionalService? = service(of: serviceTypeName)
        return impl
    }
    
    func removeService<Service>(of serviceType: Service.Type) {
        let serviceTypeName = SerivceName.value(of: serviceType)
        
        removeService(of: serviceTypeName)
    }
    
    func removeService(of serviceProtocol: Protocol) {
        let serviceTypeName = SerivceName.value(of: serviceProtocol)
        
        removeService(of: serviceTypeName)
    }
    
    func registerImpl(of implClass: AnyClass) -> ModuleRegisteredService? {
        guard let registerImplClass = implClass as? ModuleRegisteredService.Type else { return nil }
        
        let key = ObjectIdentifier(registerImplClass)
        let keepaliveRegiteredImpl = registerImplClass.keepaliveRegiteredImpl ?? false
        if keepaliveRegiteredImpl, let impl = implInstanceMap[key] {
            return impl as? ModuleRegisteredService
        }
        
        let newImpl = registerImplClass.implInstance ?? registerImplClass.init()
        // save impl of this class if it is possible
        if keepaliveRegiteredImpl { implInstanceMap[key] = newImpl }
        
        return newImpl as? ModuleRegisteredService
    }
    
//    #if DEBUG
//        public func mapInfoPrettyPrinted() {
//            let map: [ String: Any] = [
//                "serviceTypeMap": serviceTypeMap.map { ["\($0)", "\($1)"] },
//                "implInstanceMap": implInstanceMap.map { ["\($0)", "\($1)"] }
//                    ]
//            guard let jsonData = try? JSONSerialization.data(withJSONObject: map, options: .prettyPrinted) else {
//                return
//            }
//
//            let jsonString = String(data: jsonData, encoding: .utf8) ?? ""
//            print(jsonString)
//        }
//    #endif
    
    private func register(service serviceTypeName: String, used implClass: AnyClass) {
        guard let newImplClass = implClass as? ModuleFunctionalService.Type else {
            assertionFailure("\(serviceTypeName) must conforms to service `ModuleFunctionalService`")
            return
        }
        
        let identifier = serviceTypeName
        guard let oldImplClass = serviceTypeMap[identifier] else {
            serviceTypeMap[identifier] = newImplClass
            return
        }
        
        if (oldImplClass.implPriority ?? 0) < (newImplClass.implPriority ?? 0) {
            serviceTypeMap[identifier] = newImplClass
        }
    }
    
    private func service<Service>(of serviceTypeName: String) -> Service? {
        guard let implClass = serviceTypeMap[serviceTypeName] else {
            assertionFailure("the impl class of \(serviceTypeName) is nil, please register it first")
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
        let newImpl = implClass.implInstance ?? implClass.init()
#if DEBUG
        implClassList.removeAll()
#endif
        implInstanceMap[implKey] = newImpl
        
        return newImpl as? Service
    }
    
    private func removeService(of serviceTypeName: String) {
        guard let implClass = serviceTypeMap.removeValue(forKey: serviceTypeName) else { return }
        
        if (implClass as? ModuleRegisteredService.Type)?.keepaliveRegiteredImpl ?? false { return }
        if let _  = serviceTypeMap.first(where: { _, value in value == implClass }) { return }
        implInstanceMap.removeValue(forKey: ObjectIdentifier(implClass))
    }
}

struct SerivceName {
    
    static func value(of aProtocol: Protocol) -> String {
        NSStringFromProtocol(aProtocol)
    }
    
    static func value<Generic>(of aGenericType: Generic.Type) -> String {
        String(reflecting: aGenericType).replacingOccurrences(of: ".Protocol", with: "")
    }
}

