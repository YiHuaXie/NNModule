//
//  Router.swift
//  Router
//
//  Created by NeroXie on 2019/1/7.
//

import Foundation

fileprivate var globalRedirectRoutesMap: [String: String] = [:]

public typealias HandleRouteFactory = (_ url: RouteURL, _ navigator: NavigatorType) -> Bool

// MARK: - URLRouterType

public protocol URLRouterType: AnyObject {
    
    /// a route paraser converts URL or String to RouteURL.
    var routeParser: URLRouteParserType { set get }
    
    /// Registers an URL
    /// - Parameters:
    ///   - route: The route name
    ///   - handleRouteFactory: The route handler
    func registerRoute(_ route: URLRouteConvertible, handleRouteFactory: @escaping HandleRouteFactory)
    
    /// Registers an URL
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

public extension URLRouterType {
    
    /// The default route to handle the URL has http or https
    var webLink: URLRouteConvertible { "weblink" }
    
    /// redirect routes
    var redirectRoutesMap: [String: String] { globalRedirectRoutesMap }
    
    /// update global redirect routes
    /// - Parameter map: original redirect routes
    func updateRedirectRoutes(_ map: [String: String]) {
        globalRedirectRoutesMap = [:]
        map.forEach {
            if let routeUrl = routeParser.routeUrl(from: $0) {
                globalRedirectRoutesMap[routeUrl.identifier] = $1
            }
        }
    }
    
    @discardableResult
    func openRoute(_ route: URLRouteConvertible, parameters: [String: Any] = [:]) -> Bool {
        openRoute(route, parameters: parameters)
    }
}

// MARK: - Router

public class URLRouter: URLRouterType {
    
    private typealias RouteRedirectData = RouteOriginalData
    
    private var handleRouteFactories = [String: HandleRouteFactory]()
    
    private var lazyRegisters: [(URLRouterType) -> Void] = []
    
    public static let `default` = URLRouter()
    
    public var routeParser: URLRouteParserType = URLRouteParser()
    
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
        if let redirectRouteData = self.redirectRouteData(from: routeUrl)  {
            return openRoute(redirectRouteData.route, parameters: redirectRouteData.params)
        }
        
        // handle web link
        if routeUrl.isWebLink {
            if let handler = findRouteHandler(with: routeUrl) {
                return handler(routeUrl, Navigator.default)
            }
            
            if let webLinkRouteUrl = routeParser.routeUrl(from: webLink),
               let webLinkHandler = findRouteHandler(with: webLinkRouteUrl) {
                return webLinkHandler(routeUrl, Navigator.default)
            }
            
            URLRouterLog("route for (\(route)) is web link, please register handler for web links")
            return false
        }
        
        guard let handler = findRouteHandler(with: routeUrl) else {
            URLRouterLog("route for (\(route)) is not exist")
            return false
        }
        
        return handler(routeUrl, Navigator.default)
    }
    
    public func addLazyRegister(_ register: @escaping (URLRouterType) -> Void) {
        lazyRegisters.append(register)
    }
    
    private func redirectRouteData(from originalRouteUrl: RouteURL) -> RouteRedirectData? {
        guard let redirectRoute = redirectRoutesMap[originalRouteUrl.identifier] else {
            return nil
        }
        
        var newParameters = originalRouteUrl.parameters
        if originalRouteUrl.isWebLink { newParameters.removeValue(forKey: "url") }
        return (redirectRoute, newParameters)
    }
    
    private func findRouteHandler(with routeUrl: RouteURL) -> HandleRouteFactory? {
        if let handler = handleRouteFactories[routeUrl.identifier]  { return handler }
        
        if let combinedRouteUrl = routeParser.routeUrl(from: routeUrl.combinedRoute),
           let combinedHandler = handleRouteFactories[combinedRouteUrl.identifier] {
            return combinedHandler
        }
        
        return nil
    }
    
    private func loadLazyRegistersIfNeed() {
        guard lazyRegisters.count > 0 else { return }
        
        lazyRegisters.forEach { register in register(self) }
        lazyRegisters.removeAll()
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
