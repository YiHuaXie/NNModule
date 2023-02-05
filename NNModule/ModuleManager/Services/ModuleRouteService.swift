//
//  ModuleRouteService.swift
//  ModuleManager
//
//  Created by NeroXie on 2019/1/18.
//

import Foundation

/// Services used to provide routing
@objc public protocol ModuleRouteService: ModuleFunctionalService, URLNestingRouterType, URLRouterTypeAttach {}

@objc extension URLRouter: ModuleRouteService {
    
    public static var implInstance: ModuleBasicService { URLRouter.default }
}


