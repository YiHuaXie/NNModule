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
    
    private var proxyList: [ServiceBridgeProxy] = []
    
    private(set) var serviceTypeMap: [ServiceIdentifier: ModuleFunctionalService.Type] = [:]
    
    private var implInstanceMap: [ObjectIdentifier: ModuleBasicService] = [:]
    
#if DEBUG
    private var implClassList: [String] = []
#endif
    
    private init() {}
    
    func registerService(of identifier: ServiceIdentifier, used implClass: AnyClass) {
        guard let newImplClass = implClass as? ModuleFunctionalService.Type else {
            assertionFailure("\(identifier.value) must conforms to service `ModuleFunctionalService`")
            return
        }
        
        guard let oldImplClass = serviceTypeMap[identifier] else {
            serviceTypeMap[identifier] = newImplClass
            return
        }
        
        if (oldImplClass.implPriority ?? 0) < (newImplClass.implPriority ?? 0) {
            serviceTypeMap[identifier] = newImplClass
        }
    }
    
    func serviceImpl(of identifier: ServiceIdentifier) -> ModuleFunctionalService? {
        guard let proxy = proxyList.first(where: { $0.identifier == identifier.value }) else {
            return serviceNativeImpl(of: identifier)
        }
        
        guard let nativeImpl = serviceNativeImpl(of: identifier) else {
            proxyList.removeAll { $0.identifier == identifier.value }
            return nil
        }
        
        proxy.nativeImpl = nativeImpl
        return proxy as? ModuleFunctionalService
    }
    
    func serviceNativeImpl(of identifier: ServiceIdentifier) -> ModuleFunctionalService? {
        guard let implClass = serviceTypeMap[identifier] else {
            assertionFailure("the impl class of \(identifier.value) is nil, please register it first")
            return nil
        }
        
        let implKey = ObjectIdentifier(implClass)
        if let impl = implInstanceMap[implKey] as? ModuleFunctionalService { return impl }
        
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
        
        return newImpl as? ModuleFunctionalService
    }
    
    func registerImpl(of implClass: AnyClass) -> ModuleRegisteredService? {
        guard let registerImplClass = implClass as? ModuleRegisteredService.Type else {
            return nil
        }
        
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
    
    func removeService(of identifier: ServiceIdentifier) {
        guard let implClass = serviceTypeMap.removeValue(forKey: identifier) else { return }
        
        if (implClass as? ModuleRegisteredService.Type)?.keepaliveRegiteredImpl ?? false { return }
        if let _  = serviceTypeMap.first(where: { _, value in value == implClass }) { return }
        implInstanceMap.removeValue(forKey: ObjectIdentifier(implClass))
    }
    
    func bridge(method: Selector, isClassMethod: Bool, of identifier: ServiceIdentifier, used aClass: AnyClass) {
        guard let _  = aClass as? ModuleServiceBridgeEnable.Type else {
            assertionFailure("\(aClass) must conforms to service `ModuleServiceBridgeEnable`")
            return
        }
        
        guard let _ = serviceTypeMap[identifier] else {
            assertionFailure("the impl class of \(identifier.value) is nil, please register it first")
            return
        }
        
        var proxy = proxyList.first { $0.identifier == identifier.value }
        if proxy == nil {
            proxy = ServiceBridgeProxy(identifier: identifier.value)
            proxyList.append(proxy!)
        }
        
        proxy?.setBridgeClass(aClass, forMethod: method, isClassMethod: isClassMethod)
    }
    
    func serviceInfoPrettyPrinted() {
#if DEBUG
        let newProxyList = proxyList.map {
            guard let data = $0.description.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any] else {
                return [String: Any]()
            }
            
            return json
        }
        
        let map: [ String: Any] = [
            "bridgeProxyList": newProxyList,
            "serviceTypeMap": Dictionary(uniqueKeysWithValues: serviceTypeMap.map { ("\($0)", "\($1)") }) ,
            "implInstanceMap": Dictionary(uniqueKeysWithValues: implInstanceMap.map { ("\($0)", "\($1)") })
        ]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: map, options: .prettyPrinted) else {
            return
        }
        
        let jsonString = String(data: jsonData, encoding: .utf8) ?? ""
        print(jsonString)
#endif
    }
}
