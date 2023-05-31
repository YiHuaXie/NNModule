//
//  ModuleBasicService.swift
//  Module
//
//  Created by NeroXie on 2019/1/18.
//

import Foundation

/// Basic service.
/// All services must be based on this service.
@objc public protocol ModuleBasicService: NSObjectProtocol {
    
    /// Init Method.
    init()
    
    /// The instance of implementing service.
    @objc optional static var implInstance: ModuleBasicService { get }
}

/// Functional service
@objc public protocol ModuleFunctionalService: ModuleBasicService {
    
    /// priority of instance, default is 0
    @objc optional static var implPriority: Int { get }
}

/// Register service.
@objc public protocol ModuleRegisteredService: ModuleBasicService {
    
    /// keep alive the instance
    /// It will save the instance to a global map when return true.
    @objc optional static var keepaliveRegiteredImpl: Bool { get }
}

/// Functional service birdge.
@objc public protocol ModuleServiceBridgeEnable: ModuleRegisteredService {}
