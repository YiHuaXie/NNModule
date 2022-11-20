//
//  URLRouterType.swift
//  ApplicationModule
//
//  Created by NeroXie on 2022/11/20.
//

import Foundation

public typealias HandleRouteFactory = (_ routeUrl: RouteURL, _ navigator: NavigatorType) -> Bool

public protocol URLRouterType: AnyObject {
    
    /// A route paraser converts URL or String to RouteURL.
    var routeParser: URLRouteParserType { get }
    
    /// A navigator push or present view controller.
    var navigator: NavigatorType { get }
    
    /// A redirector for redirecting routes.
    var routeRedirector: URLRouteRedirector { get }
    
    /// Route interceptor.
    var routeInterceptor: URLRouteInterceptor { get }
    
    /// Upper-level router of the current router.
    var upperRouter: URLRouterType? { get }
    
    /// Registers a route with a route handler.
    /// - Parameters:
    ///   - route: The route name
    ///   - handleRouteFactory: The route handler to call when the route is matched.
    func delayedRegisterRoute(_ route: URLRouteConvertible, handleRouteFactory: @escaping HandleRouteFactory)
    
    /// Registers a route with a route handler.
    /// - Parameters:
    ///   - route: The route name.
    ///   - handleRouteFactory: The route handler to call when the route is matched.
    func registerRoute(_ route: URLRouteConvertible, handleRouteFactory: @escaping HandleRouteFactory)
    
    /// Registers an URL with a subRouter.
    /// - Parameters:
    ///   - route: The route name.
    ///   - subRouter: A subrouter which can handle the route.
    func registerRoute(_ route: URLRouteConvertible, used subRouter: URLRouterType)
    
    /// Remove a route.
    /// - Parameter route: The route name.
    func removeRoute(_ route: URLRouteConvertible)
    
    /// Removes all routes.
    func removeAllRoutes()
    
    @discardableResult
    /// Executes a route open handler.
    /// - Parameters:
    ///   - route: The route name.
    ///   - parameters: The route parameters.
    /// - Returns: Bool
    func openRoute(_ route: URLRouteConvertible, parameters: [String: Any]) -> Bool
}

extension URLRouterType {
    
    /// The default route to handle the URL has http or https.
    public var webLink: URLRouteConvertible { "weblink" }
    
    public var routeRedirector: URLRouteRedirector {
        assertionFailure("router for \(self) does not support using URLRouteRedirector.")
        return URLRouteRedirector(with: routeParser)
    }
    
    public var routeInterceptor: URLRouteInterceptor {
        assertionFailure("router for \(self) does not support using URLRouteInterceptor.")
        return URLRouteInterceptor(with: routeParser)
    }
    
    public var upperRouter: URLRouterType? {
        assertionFailure("router for \(self) does not support router nesting.")
        return nil
    }
    
    @discardableResult
    public func openRoute(_ route: URLRouteConvertible, parameters: [String: Any] = [:]) -> Bool {
        openRoute(route, parameters: parameters)
    }
    
    public func registerRoutes(_ routes: [URLRouteConvertible], used subRouter: URLRouterType) {
        routes.forEach { registerRoute($0, used: subRouter) }
    }
    
    public func registerRoute(_ route: URLRouteConvertible, used subRouter: URLRouterType) {
        assertionFailure("router for \(self) does not support using router nesting.")
    }
    
    public func delayedRegisterRoute(_ route: URLRouteConvertible, handleRouteFactory: @escaping HandleRouteFactory) {
        assertionFailure("router for \(self) does not support using route delayed registration.")
    }
}
