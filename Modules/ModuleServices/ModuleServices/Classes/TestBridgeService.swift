//
//  TestBridgeService.swift
//  ModuleServices
//
//  Created by NeroXie on 2023/5/29.
//

import Foundation
import NNModule_swift

@objc public protocol ATestBridgeService: ModuleFunctionalService {
    
    func a_testMethod()
    
    static func a_1_testMethod()
}

@objc public protocol BTestBridgeService: ModuleFunctionalService {
    
    func b_testMethod()
    
    static func b_1_testMethod()
}


