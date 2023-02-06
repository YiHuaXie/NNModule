//
//  URLRouterType.swift
//  ApplicationModule
//
//  Created by NeroXie on 2022/11/20.
//

import Foundation

public typealias HandleRouteFactory = (_ routeUrl: RouteURL, _ navigator: NavigatorType) -> Bool

// MARK: - URLRouterType

@objc public protocol URLRouterType: NSObjectProtocol {
    
    /// A route paraser converts URL or String to RouteURL.
    var routeParser: URLRouteParserType { get }
    
    /// A navigator push or present view controller.
    var navigator: NavigatorType { get }
    
    /// Registers a route with a route handler.
    /// - Parameters:
    ///   - route: The route name
    ///   - handleRouteFactory: The route handler to call when the route is matched.
    func delayedRegisterRoute(_ route: URLRouteName, handleRouteFactory: @escaping HandleRouteFactory)
    
    /// Registers a route with a route handler.
    /// - Parameters:
    ///   - route: The route name.
    ///   - handleRouteFactory: The route handler to call when the route is matched.
    func registerRoute(_ route: URLRouteName, handleRouteFactory: @escaping HandleRouteFactory)

    /// Remove a route.
    /// - Parameter route: The route name.
    func removeRoute(_ route: URLRouteName)
    
    /// Removes all routes.
    func removeAllRoutes()
    
    @discardableResult
    /// Executes a route open handler.
    /// - Parameters:
    ///   - route: The route name.
    ///   - parameters: The route parameters.
    /// - Returns: Bool
    func openRoute(_ route: URLRouteName, parameters: [String: Any]) -> Bool
}

extension URLRouterType {
        
    @discardableResult
    public func openRoute(_ route: URLRouteName, parameters: [String: Any] = [:]) -> Bool {
        openRoute(route, parameters: parameters)
    }
}

// MARK: - URLNestingRouterType

/// A protocol to support route nesting.
@objc public protocol URLNestingRouterType: URLRouterType {
    
    /// Upper-level router of the current router.
    weak var upperRouter: URLNestingRouterType? { get }
    
    /// Registers an URL with a subRouter.
    /// - Parameters:
    ///   - route: The route name.
    ///   - subRouter: A subrouter which can handle the route.
    func registerRoute(_ route: URLRouteName, used subRouter: URLNestingRouterType)
}

public extension URLNestingRouterType {
    
    func registerRoutes(_ routes: [URLRouteName], used subRouter: URLNestingRouterType) {
        routes.forEach { registerRoute($0, used: subRouter) }
    }
}

// MARK: - URLRouterTypeAttach

@objc public protocol URLRouterTypeAttach: NSObjectProtocol {
    
    /// A redirector for redirecting routes.
    var routeRedirector: URLRouteRedirector { get }
    
    /// A route interceptor that decides whether to execute the route.
    var routeInterceptor: URLRouteInterceptor { get }
}

