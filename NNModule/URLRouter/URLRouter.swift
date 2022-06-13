//
//  Router.swift
//  Router
//
//  Created by NeroXie on 2019/1/7.
//

import Foundation

/// A global map used to store redirect routing tables.
fileprivate var globalRedirectRoutesMap: [String: String] = [:]

fileprivate var lazyRegistersKey: Void?

public typealias HandleRouteFactory = (_ url: RouteURL, _ navigator: NavigatorType) -> Bool

public typealias RouteRedirectData = RouteOriginalData

// MARK: - URLRouterType

public protocol URLRouterType: AnyObject {
    
    /// a route paraser converts URL or String to RouteURL.
    var routeParser: URLRouteParserType { set get }
    
    /// a navigator push or present view controller.
    var navigator: NavigatorType { get }
    
    /// Registers an URL.
    /// - Parameters:
    ///   - route: The route name
    ///   - handleRouteFactory: The route handler
    func registerRoute(_ route: URLRouteConvertible, handleRouteFactory: @escaping HandleRouteFactory)
    
    /// Registers an URL.
    /// - Parameters:
    ///   - route: The route name
    ///   - combiner: The combiner to handle some route
    func registerRoute(_ route: URLRouteConvertible, combiner: URLRouteCombine)
    
    @discardableResult
    /// Executes an URL open handler.
    /// - Parameters:
    ///   - route: The route name
    ///   - parameters: The route parameters
    /// - Returns: Bool
    func openRoute(_ route: URLRouteConvertible, parameters: [String: Any]) -> Bool
}

extension URLRouterType {
    
    /// The default route to handle the URL has http or https.
    public var webLink: URLRouteConvertible { "weblink" }
    
    /// Update global redirect routes.
    /// - Parameter map: original redirect routes
    public func updateRedirectRoutes(_ map: [String: String]) {
        globalRedirectRoutesMap = [:]
        map.forEach {
            if let identifier = routeParser.routeUrl(from: $0)?.identifier {
                globalRedirectRoutesMap[identifier] = $1
            }
        }
    }
    
    /// Get redirect route via original route.
    /// - Parameter originalRouteUrl: original `RouteURL`
    /// - Returns: `RouteRedirectData`
    public func routeRedirectData(from originalRouteUrl: RouteURL) -> RouteRedirectData? {
        guard let redirectRoute = globalRedirectRoutesMap[originalRouteUrl.identifier] else { return nil }
        
        var redirectParams = originalRouteUrl.parameters
        if originalRouteUrl.isWebLink { redirectParams.removeValue(forKey: "url") }
        
        return (redirectRoute, redirectParams)
    }
        
    /// Add lazy route registration
    /// - Parameter register: lazy route registration
    public func addLazyRegister(_ register: @escaping (URLRouterType) -> Void) {
        var registers = objc_getAssociatedObject(self, &lazyRegistersKey) as? [(URLRouterType) -> Void] ?? []
        registers.append(register)
        objc_setAssociatedObject(self, &lazyRegistersKey, registers, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    /// Load all lazy route registration
    public func loadLazyRegistersIfNeed() {
        let registers = objc_getAssociatedObject(self, &lazyRegistersKey) as? [(URLRouterType) -> Void] ?? []
        guard registers.count > 0 else { return }
        
        registers.forEach { register in register(self) }
        objc_setAssociatedObject(self, &lazyRegistersKey, [], .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    @discardableResult
    public func openRoute(_ route: URLRouteConvertible, parameters: [String: Any] = [:]) -> Bool {
        openRoute(route, parameters: parameters)
    }
}

// MARK: - Router

public class URLRouter: URLRouterType {
    
    private var handleRouteFactories = [String: HandleRouteFactory]()
    
    public static let `default` = URLRouter()
    
    public var routeParser: URLRouteParserType = URLRouteParser()
    
    public var navigator: NavigatorType { Navigator.default }
    
    public required init() {}
    
    public func registerRoute(_ route: URLRouteConvertible, handleRouteFactory: @escaping HandleRouteFactory) {
        guard let routeUrl = routeParser.routeUrl(from: route) else {
            URLRouterLog("route for (\(route)) is invalid")
            return
        }
        
        let key = routeUrl.identifier
        if handleRouteFactories[key] != nil {
            URLRouterLog("route for (\(route)) already exist")
            return
        }
        
        handleRouteFactories[key] = handleRouteFactory
    }

    public func registerRoute(_ route: URLRouteConvertible, combiner: URLRouteCombine) {
        guard let routeUrl = routeParser.routeUrl(from: route) else {
            URLRouterLog("route for (\(route)) is invalid")
            return
        }
        
        registerRoute(routeUrl.combinedRoute) {
            combiner.handleRoute(with: $0, navigator: $1)
        }
    }
    
    @discardableResult
    public func openRoute(_ route: URLRouteConvertible, parameters: [String: Any]) -> Bool {
        loadLazyRegistersIfNeed()
        guard let routeUrl = routeParser.routeUrl(from: route, params: parameters) else {
            URLRouterLog("route for (\(route)) is invalid")
            return false
        }
        
        // fix redirect route
        if let redirectData = routeRedirectData(from: routeUrl)  {
            return openRoute(redirectData.route, parameters: redirectData.params)
        }
        
        // handle web link
        if routeUrl.isWebLink {
            if let handler = findRouteHandler(with: routeUrl) {
                return handler(routeUrl, navigator)
            }
            
            if let webLinkRouteUrl = routeParser.routeUrl(from: webLink),
               let webLinkHandler = findRouteHandler(with: webLinkRouteUrl) {
                return webLinkHandler(routeUrl, navigator)
            }
            
            URLRouterLog("route for (\(route)) is web link, please register handler for web links")
            return false
        }
        
        guard let handler = findRouteHandler(with: routeUrl) else {
            URLRouterLog("route for (\(route)) is not exist")
            return false
        }
        
        return handler(routeUrl, navigator)
    }
    
    private func findRouteHandler(with routeUrl: RouteURL) -> HandleRouteFactory? {
        if let handler = handleRouteFactories[routeUrl.identifier]  { return handler }
        
        if let combinedRouteUrl = routeParser.routeUrl(from: routeUrl.combinedRoute),
           let combinedHandler = handleRouteFactories[combinedRouteUrl.identifier] {
            return combinedHandler
        }
        
        return nil
    }
}

extension URLRouter: URLRouteCombine {
    
    public func handleRoute(with routeUrl: RouteURL, navigator: NavigatorType) -> Bool {
        let originalData = routeUrl.originalData
        return openRoute(originalData.route, parameters: originalData.params)
    }
}

fileprivate func URLRouterLog<T>(_ message: T) {
#if DEBUG
    print("URLRouter Error ⚠️ :\(message)")
#endif
}
