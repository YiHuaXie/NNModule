//
//  Router.swift
//  Router
//
//  Created by NeroXie on 2019/1/7.
//

import Foundation

public typealias HandleRouteFactory = (_ url: RouteURL, _ navigator: NavigatorType) -> Bool

// MARK: - RouteManagement

public protocol URLRouterType: AnyObject {
    
    /// a route paraser converts URL or String to RouteURL.
    var routeParser: URLRouteParserType { set get }
    
    /// Registers an URL
    /// - Parameters:
    ///   - route: The route name
    ///   - handleRouteFactory: The route handler
    func registerRoute(_ route: URLRouteConvertible, _ handleRouteFactory: @escaping HandleRouteFactory)
    
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
    
    @discardableResult
    func openRoute(_ route: URLRouteConvertible, parameters: [String: Any] = [:]) -> Bool {
        openRoute(route, parameters: parameters)
    }
    
    /// The default route to handle the URL has http or https
    var webLink: URLRouteConvertible { "weblink" }
}

// MARK: - Router

public class URLRouter: URLRouterType {
    
    public static let `default` = URLRouter()
    
    public var routeParser: URLRouteParserType = URLRouteParser()
    
    private var handleRouteFactories = [String: HandleRouteFactory]()
    
    public var lazyRegister: (URLRouterType) -> Void = { _ in }
    
    private var didLoadLazyRegister = false
    
    public required init() {}
    
    public func registerRoute(_ route: URLRouteConvertible, _ handleRouteFactory: @escaping HandleRouteFactory) {
        guard let routeUrl = routeParser.routeUrl(from: route) else {
            log("route for (\(route)) is invalid")
            return
        }
        
        let key = handleRouteFactoryKey(from: routeUrl)
        if handleRouteFactories[key] != nil {
            log("route for (\(route)) already exist")
            return
        }
        
        handleRouteFactories[key] = handleRouteFactory
    }
    
    public func registerRoute(_ route: URLRouteConvertible, combiner: URLRouteCombine) {
        guard let routeUrl = routeParser.routeUrl(from: route) else {
            log("route for (\(route)) is invalid")
            return
        }
        
        let newRoute = "\(routeUrl.scheme)://\(routeUrl.host)"
        registerRoute(newRoute) { [weak combiner] url, navigator in
            combiner?.handleRoute(with: url, navigator: navigator) ?? false
        }
    }
    
    @discardableResult
    public func openRoute(_ route: URLRouteConvertible, parameters: [String: Any]) -> Bool {
        if !didLoadLazyRegister {
            lazyRegister(self)
            didLoadLazyRegister = true
        }
        
        guard let routeUrl = routeParser.routeUrl(from: route, params: parameters) else {
            log("route for (\(route)) is invalid")
            return false
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
            
            log("route for (\(route)) is web link, please register handler for web links")
            return false
        }
        
        guard let handler = findRouteHandler(with: routeUrl) else {
            log("route for (\(route)) is not exist")
            return false
        }
        
        return handler(routeUrl, Navigator.default)
    }
    
    private func findRouteHandler(with routeUrl: RouteURL) -> HandleRouteFactory? {
        let key = handleRouteFactoryKey(from: routeUrl)
        if let handler = handleRouteFactories[key]  { return handler }
        
        let combinerRoute = "\(routeUrl.scheme)://\(routeUrl.host)"
        if let combinerRouteUrl = routeParser.routeUrl(from: combinerRoute) {
            let combinerKey = handleRouteFactoryKey(from: combinerRouteUrl)
            if let combinerHandler = handleRouteFactories[combinerKey] { return combinerHandler }
        }
        
        return nil
    }
    
    private func log<T>(_ message: T) {
#if DEBUG
        print("URLRouter Error ⚠️ :\(message)")
#endif
    }
    
    private func handleRouteFactoryKey(from routeUrl: RouteURL) -> String {
        routeUrl.scheme.lowercased() + routeUrl.host.lowercased() + routeUrl.path
    }
}

extension URLRouter: URLRouteCombine {
    
    public func handleRoute(with routeUrl: RouteURL, navigator: NavigatorType) -> Bool {
        let originalData = routeUrl.originalData
        return openRoute(originalData.route, parameters: originalData.params)
    }
}

