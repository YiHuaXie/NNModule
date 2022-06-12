//
//  ModuleRouteService.swift
//  ModuleManager
//
//  Created by NeroXie on 2019/1/18.
//

import Foundation

/// Services used to provide routing
public protocol ModuleRouteService: ModuleFunctionalService, URLRouterType {
    
    func addLazyRegister(_ register: @escaping (URLRouterType) -> Void)
}

extension URLRouter: ModuleRouteService {
        
    public static var serviceImpl: ModuleBasicService { URLRouter.default }
}


