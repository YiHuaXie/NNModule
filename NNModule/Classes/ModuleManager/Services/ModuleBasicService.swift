//
//  ModuleBasicService.swift
//  Module
//
//  Created by NeroXie on 2019/1/18.
//

import Foundation

/// Basic service.
/// All services must be based on this service.
public protocol ModuleBasicService: AnyObject {
    
    /// Init Method.
    init()
    
    /// The instance of implementing service.
    static var implInstance: Self { get }
}

public extension ModuleBasicService {
    
    static var implInstance: Self { self.init() }
}

/// Functional service
public protocol ModuleFunctionalService: ModuleBasicService {
    
    /// priority of instance, default is 0
    static var implPriority: Int { get }
}

public extension ModuleFunctionalService {
    
    static var implPriority: Int { 0 }
}

/// Register service.
public protocol ModuleRegisteredService: ModuleBasicService {
    
    /// keep alive the instance
    /// It will save the instance to a global map when return true.
    static var keepaliveRegiteredImpl: Bool { get }
}

public extension ModuleRegisteredService {
    
    static var keepaliveRegiteredImpl: Bool { false }
}


