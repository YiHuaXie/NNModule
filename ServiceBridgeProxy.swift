////
////  ServiceBridgeProxy.swift
////  NNModule-swift
////
////  Created by NeroXie on 2023/5/30.
////
//
//import Foundation
//
//final class ServiceBridgeProxy: NSObject {
//    
//    fileprivate(set) var identifier = ServiceIdentifier(ModuleBasicService.self)
//
//    weak var nativeImpl: AnyObject? = nil {
//        didSet { type(of: self).nativeImplClass = nativeImpl == nil ? nil : type(of: nativeImpl!) }
//    }
//    
//    private var instanceMethodMap: NSMapTable<NSString, AnyObject> = .strongToWeakObjects()
//    
//    private static var classMethodMap: [String: AnyClass] {
//        set { objc_setAssociatedObject(self, &classMethodMapKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
//        
//        get {
//            if let map = objc_getAssociatedObject(self, &classMethodMapKey) as? [String: AnyClass] { return map }
//            
//            let map = [String: AnyClass]()
//            objc_setAssociatedObject(self, &classMethodMapKey, map, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//            
//            return map
//        }
//    }
//    
//    private static var nativeImplClass: AnyClass? {
//        set { objc_setAssociatedObject(self, &nativeImplClassKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
//        
//        get { objc_getAssociatedObject(self, &nativeImplClassKey) as? AnyClass }
//    }
//    
//    required override init() {}
//    
//    class func proxy(identifier: ServiceIdentifier) -> ServiceBridgeProxy? {
//        guard let bridgeClass = objc_allocateClassPair(ServiceBridgeProxy.self, "\(identifier.value)_BridgeProxy", 0) else {
//            return nil
//        }
//        
//        objc_registerClassPair(bridgeClass)
//        let proxy = (bridgeClass as! ServiceBridgeProxy.Type).init()
//        proxy.identifier = identifier
//        
////        print(NSStringFromClass(bridgeClass))
////        print(proxy)
////        print(type(of: proxy))
//        return proxy
//    }
//    
//    func set(bridgeClass: AnyClass, for method: Selector, isClassMethod: Bool) {
//        if isClassMethod {
//            type(of: self).classMethodMap[NSStringFromSelector(method)] = bridgeClass
//        } else if let bridgeImpl = Module.registerImpl(of: bridgeClass) {
//            instanceMethodMap.setObject(bridgeImpl, forKey: NSStringFromSelector(method) as NSString)
//        }
//    }
//    
//    override func forwardingTarget(for aSelector: Selector!) -> Any? {
//        let methodKey = NSStringFromSelector(aSelector) as NSString
//        guard let bridgeImpl = instanceMethodMap.object(forKey: methodKey), bridgeImpl.responds(to: aSelector) else {
//            return nativeImpl
//        }
//        
//        return bridgeImpl
//    }
//
//    override class func forwardingTarget(for aSelector: Selector!) -> Any? {
//        print(self)
//        print(classMethodMap)
//        let methodKey = NSStringFromSelector(aSelector)
//        guard let bridgeClass = classMethodMap[methodKey], bridgeClass.responds(to: aSelector) else {
//            return nativeImplClass
//        }
//        
//        return bridgeClass
//    }
//    
//    override func conforms(to aProtocol: Protocol) -> Bool {
//        nativeImpl?.conforms(to: aProtocol) ?? false
//    }
//    
//    override func isProxy() -> Bool { true }
//}
//
////fileprivate protocol ServiceBridgeProxyInitialize {
////
////    var identifier: ServiceIdentifier { get }
////
////    init(identifier: ServiceIdentifier)
////}
//
//private var classMethodMapKey: Void?
//
//private var nativeImplClassKey: Void?
