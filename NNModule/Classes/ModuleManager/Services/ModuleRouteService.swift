//
//  ModuleRouteService.swift
//  ModuleManager
//
//  Created by NeroXie on 2019/1/18.
//

import Foundation

/// Services used to provide routing
public protocol ModuleRouteService: ModuleFunctionalService, URLRouterType {}

extension ModuleRouteService {
    
    /// Returns the default scheme of Router
    public var defaultScheme: String { routeParser.defaultScheme }
    
    /// Update defaultScheme
    /// - Parameter defaultScheme: default scheme
    public func update(defaultScheme: String) {
        routeParser.defaultScheme = defaultScheme
    }
}

extension URLRouter: ModuleRouteService {
        
    public static var serviceImpl: ModuleBasicService { URLRouter.default }
}


