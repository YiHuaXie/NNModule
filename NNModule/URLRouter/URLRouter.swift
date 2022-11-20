//
//  Router.swift
//  Router
//
//  Created by NeroXie on 2019/1/7.
//

import Foundation

public class URLRouter: URLRouterType {
    
    private var _routeParser: URLRouteParserType = URLRouteParser()
    
    private var _navigator: NavigatorType = Navigator()
    
    private var _routeRedirector = URLRouteRedirector()
    
    private var _routeInterceptor = URLRouteInterceptor()
    
    private var delayedHandlers = [(URLRouterType) -> Void]()
    
    private var handleRouteFactories = [String: HandleRouteFactory]()
    
    public private(set) weak var upperRouter: URLRouterType? = nil
    
    public var routeParser: URLRouteParserType { upperRouter?.routeParser ?? _routeParser }
    
    public var navigator: NavigatorType { upperRouter?.navigator ?? _navigator }
    
    public var routeRedirector: URLRouteRedirector { upperRouter?.routeRedirector ?? _routeRedirector }
    
    public var routeInterceptor: URLRouteInterceptor { upperRouter?.routeInterceptor ?? _routeInterceptor }
    
    public static var `default` = URLRouter()
    
    public required init() {}
    
    public required init(routeParser: URLRouteParserType, navigator: NavigatorType = Navigator()) {
        _routeParser = routeParser
        _navigator = navigator
        _routeRedirector = URLRouteRedirector(with: routeParser)
        _routeInterceptor = URLRouteInterceptor(with: routeParser)
    }
    
    public convenience init(with router: URLRouterType) {
        self.init(routeParser: router.routeParser, navigator: router.navigator)
        
        _routeInterceptor = router.routeInterceptor
        _routeRedirector = router.routeRedirector
        upperRouter = router
    }
    
    public func delayedRegisterRoute(_ route: URLRouteConvertible, handleRouteFactory: @escaping HandleRouteFactory) {
        delayedHandlers.append { $0.registerRoute(route, handleRouteFactory: handleRouteFactory) }
    }
    
    public func registerRoute(_ route: URLRouteConvertible, handleRouteFactory: @escaping HandleRouteFactory) {
        guard let routeUrl = routeParser.routeUrl(from: route) else {
            URLRouterLog("route for (\(route)) is invalid")
            return
        }
        
        let key = routeUrl.fullPath
        if handleRouteFactories[key] != nil {
            URLRouterLog("route for (\(route)) already exist")
            return
        }
        
        handleRouteFactories[key] = handleRouteFactory
    }
    
    public func registerRoute(_ route: URLRouteConvertible, used subRouter: URLRouterType) {
        guard subRouter.upperRouter === self else {
            URLRouterLog("upper router for (\(subRouter)) is not \(self)")
            return
        }
        
        guard let routeUrl = routeParser.routeUrl(from: route) else {
            URLRouterLog("route for (\(route)) is invalid")
            return
        }
        
        registerRoute(routeUrl.combinedRoute) { routeUrl, _ in
            subRouter.openRoute(routeUrl.fullPath, parameters: routeUrl.parameters)
        }
    }
    
    public func removeRoute(_ route: URLRouteConvertible) {
        guard let routeUrl = routeParser.routeUrl(from: route) else {
            URLRouterLog("route for (\(route)) is invalid")
            return
        }
        
        let key = routeUrl.fullPath
        handleRouteFactories.removeValue(forKey: key)
    }
    
    public func removeAllRoutes() {
        handleRouteFactories = [:]
    }
    
    @discardableResult
    public func openRoute(_ route: URLRouteConvertible, parameters: [String: Any]) -> Bool {
        loadDelayedHandlerIfNeed()
        guard let routeUrl = routeParser.routeUrl(from: route, params: parameters) else {
            URLRouterLog("route for (\(route)) is invalid")
            return false
        }
        
        // Check if is a redirected route
        if let redirectData = routeRedirector.routeRedirectData(from: routeUrl) {
            return openRoute(redirectData.route, parameters: redirectData.params)
        }
        
        // Check if is web link
        if routeUrl.isWebLink {
            if let handler = findRouteHandler(with: routeUrl) {
                return invokeRouteHandler(handler, routeUrl: routeUrl)
            }
            
            if let webLinkRouteUrl = routeParser.routeUrl(from: webLink),
               let webLinkHandler = findRouteHandler(with: webLinkRouteUrl) {
                return invokeRouteHandler(webLinkHandler, routeUrl: routeUrl)
            }
            
            guard let upperRouter = self.upperRouter else {
                URLRouterLog("route for (\(route)) is web link, please register handler for web links")
                return false
            }
            
            return upperRouter.openRoute(route, parameters: parameters)
        }
        
        if let handler = findRouteHandler(with: routeUrl) {
            return invokeRouteHandler(handler, routeUrl: routeUrl)
        }
        
        // If the current router cannot handle the route, it will be handled by the super router.
        guard let upperRouter = self.upperRouter else {
            URLRouterLog("route for (\(route)) is not exist")
            return false
        }
        
        return upperRouter.openRoute(route, parameters: parameters)
    }
    
    private func loadDelayedHandlerIfNeed() {
        delayedHandlers.forEach { handler in handler(self) }
        delayedHandlers = []
    }
    
    private func findRouteHandler(with routeUrl: RouteURL) -> HandleRouteFactory? {
        if let handler = handleRouteFactories[routeUrl.fullPath]  { return handler }
        
        if !routeUrl.path.isEmpty,
           let combinedRouteUrl = routeParser.routeUrl(from: routeUrl.combinedRoute),
           let combinedHandler = handleRouteFactories[combinedRouteUrl.fullPath] {
            return combinedHandler
        }
        
        return nil
    }
    
    private func invokeRouteHandler(_ handler: HandleRouteFactory, routeUrl: RouteURL) -> Bool {
        var finalRouteUrl = routeUrl
        if routeInterceptor.interceptSuccessfully(for: &finalRouteUrl) { return false }
        
        return handler(finalRouteUrl, navigator)
    }
}

public func URLRouterLog<T>(_ message: T) {
#if DEBUG
    print("URLRouter Error ⚠️ :\(message)")
#endif
}

