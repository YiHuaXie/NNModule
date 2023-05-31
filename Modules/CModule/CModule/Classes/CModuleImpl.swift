//
//  CModuleImpl.swift
//  ModuleServices
//
//  Created by NeroXie on 2023/5/29.
//

import Foundation
import ModuleServices
import NNModule_swift

extension Module.RegisterService {
    
    @objc static func cModuleRegisterService() {
        Module.register(service: ATestBridgeService.self, used: ATestBridgeServiceImpl.self)
        Module.register(service: BTestBridgeService.self, used: BTestBridgeServiceImpl.self)
    }
}

extension Module.Awake {
    
    @objc static func cModuleAwake() {
        Module.bridge(method: NSSelectorFromString("a_testMethod"), of: ATestBridgeService.self, used: ATestBridgeServiceBridge.self)
        Module.bridge(method: NSSelectorFromString("b_testMethod"), of: BTestBridgeService.self, used: BTestBridgeServiceBridge.self)
        Module.bridge(classMethod: NSSelectorFromString("a_1_testMethod"), of: ATestBridgeService.self, used: ATestBridgeServiceBridge.self)
        Module.bridge(classMethod: NSSelectorFromString("b_1_testMethod"), of: BTestBridgeService.self, used: BTestBridgeServiceBridge.self)
        
        Module.routeService.registerRoute("cmodule/bridgetest") { _, _ in
            let aImpl = Module.serviceImpl(of: ATestBridgeService.self)
            aImpl.a_testMethod()
            type(of: aImpl).a_1_testMethod()
            
            let bImpl = Module.serviceImpl(of: BTestBridgeService.self)
            bImpl.b_testMethod()
            type(of: bImpl).b_1_testMethod()
            
            return true
        }
    }
}


final class ATestBridgeServiceImpl: NSObject, ATestBridgeService {
    
    func a_testMethod() {
        debugPrint("ATestBridgeServiceImpl a_testMethod")
    }
    
    static func a_1_testMethod() {
        debugPrint("ATestBridgeServiceImpl a_1_testMethod")
    }
}

final class BTestBridgeServiceImpl: NSObject, BTestBridgeService {
    
    func b_testMethod() {
        debugPrint("BTestBridgeServiceImpl b_testMethod")
    }
    
    static func b_1_testMethod() {
        debugPrint("BTestBridgeServiceImpl b_1_testMethod")
    }
}

class ATestBridgeServiceBridge: NSObject, ModuleServiceBridgeEnable {
    
    required override init() {
        super.init()
    }
    
    @objc func a_testMethod() {
        Module.serviceNativeImpl(of: ATestBridgeService.self).a_testMethod()
        debugPrint("==== ATestBridgeServiceBridge a_testMethod ====")
       
    }
    
    @objc static func a_1_testMethod() {
        type(of: Module.serviceNativeImpl(of: ATestBridgeService.self)).a_1_testMethod()
        debugPrint("==== ATestBridgeServiceBridge a_1_testMethod ====")
    }
    
    static var keepaliveRegiteredImpl: Bool { true }
}

class BTestBridgeServiceBridge: NSObject, ModuleServiceBridgeEnable {
    
    required override init() {
        super.init()
    }
    
    @objc func b_testMethod() {
        Module.serviceNativeImpl(of: BTestBridgeService.self).b_testMethod()
        debugPrint("==== BTestBridgeServiceBridge b_testMethod ====")
       
    }
    
    @objc static func b_1_testMethod() {
        type(of: Module.serviceNativeImpl(of: BTestBridgeService.self)).b_1_testMethod()
        debugPrint("==== BTestBridgeServiceBridge b_1_testMethod ====")
    }
    
    static var keepaliveRegiteredImpl: Bool { true }
}

