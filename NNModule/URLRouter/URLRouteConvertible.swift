//
//  RouteConvertible.swift
//  Router
//
//  Created by NeroXie on 2019/1/10.
//

import Foundation

/// A type which can be converted to an URL string.
public protocol URLRouteConvertible {
    
    var routeString: String { get }
}

//extension String: URLRouteConvertible {
//
//    public var routeString: String { self }
//}

extension URL: URLRouteConvertible {
    
    public var routeString: String { absoluteString }
}

public extension URLRouterType {
    
    @discardableResult
    func openRoute(_ routeConvertible: URLRouteConvertible, parameters: [String: Any] = [:]) -> Bool {
        openRoute(routeConvertible.routeString, parameters: parameters)
    }
    
    func delayedRegisterRoute(_ routeConvertible: URLRouteConvertible, handleRouteFactory: @escaping HandleRouteFactory) {
        delayedRegisterRoute(routeConvertible.routeString, handleRouteFactory: handleRouteFactory)
    }
    
    func registerRoute(_ routeConvertible: URLRouteConvertible, handleRouteFactory: @escaping HandleRouteFactory) {
        registerRoute(routeConvertible.routeString, handleRouteFactory: handleRouteFactory)
    }
    
    func removeRoute(_ routeConvertible: URLRouteConvertible) {
        removeRoute(routeConvertible.routeString)
    }
}

public extension URLRouteParserType {
    
    func routeUrl(from routeConvertible: URLRouteConvertible, params: [String: Any] = [:]) -> RouteURL? {
        routeUrl(from: routeConvertible.routeString, params: params)
    }
}

public extension URLNestingRouterType {
    
    func registerRoute(_ routeConvertible: URLRouteConvertible, used subRouter: URLNestingRouterType) {
        registerRoute(routeConvertible.routeString, used: subRouter)
    }
}

