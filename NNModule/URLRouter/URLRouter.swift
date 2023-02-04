//
//  Router.swift
//  Router
//
//  Created by NeroXie on 2019/1/7.
//

import Foundation

@objcMembers public class URLRouter: NSObject, URLNestingRouterType, URLRouterTypeAttach {

    // The default route to handle the URL has http or https.
    public static var webLink: URLRouteName { "weblink" }
    
    private var _routeParser: URLRouteParserType = URLRouteParser()
    
    private var _navigator: NavigatorType = Navigator()
    
    private var _routeRedirector: URLRouteRedirector
    
    private var _routeInterceptor: URLRouteInterceptor
    
    private var delayedHandlers = [(URLRouterType) -> Void]()
    
    private var handleRouteFactories = [String: HandleRouteFactory]()
    
    public private(set) weak var upperRouter: URLNestingRouterType? = nil
    
    public var routeParser: URLRouteParserType { upperRouter?.routeParser ?? _routeParser }
    
    public var navigator: NavigatorType { upperRouter?.navigator ?? _navigator }
    
    public var routeRedirector: URLRouteRedirector {
        (upperRouter as? URLRouterTypeAttach)?.routeRedirector ?? _routeRedirector
    }
    
    public var routeInterceptor: URLRouteInterceptor {
        (upperRouter as? URLRouterTypeAttach)?.routeInterceptor ?? _routeInterceptor
    }
    
    @objc(defaultRouter)
    public static var `default` = URLRouter()
    
    public required override init() {
        _routeRedirector = URLRouteRedirector(with: _routeParser)
        _routeInterceptor = URLRouteInterceptor(with: _routeParser)
        
        super.init()
    }
    
    public required init(routeParser: URLRouteParserType = URLRouteParser(), navigator: NavigatorType = Navigator()) {
        _routeParser = routeParser
        _navigator = navigator
        _routeRedirector = URLRouteRedirector(with: routeParser)
        _routeInterceptor = URLRouteInterceptor(with: routeParser)
        
        super.init()
    }
    
    @objc(initWithRouter:)
    public convenience init(with router: URLNestingRouterType) {
        self.init(routeParser: router.routeParser, navigator: router.navigator)
        
        upperRouter = router
        if let interceptor = (router as? URLRouterTypeAttach)?.routeInterceptor { _routeInterceptor = interceptor }
        if let redirector = (router as? URLRouterTypeAttach)?.routeRedirector { _routeRedirector = redirector }
    }
    
    public func delayedRegisterRoute(_ route: URLRouteName, handleRouteFactory: @escaping HandleRouteFactory) {
        delayedHandlers.append { $0.registerRoute(route, handleRouteFactory: handleRouteFactory) }
    }
    
    public func registerRoute(_ route: URLRouteName, handleRouteFactory: @escaping HandleRouteFactory) {
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
    
    public func registerRoute(_ route: URLRouteName, used subRouter: URLNestingRouterType) {
        guard let upperRouter = subRouter.upperRouter, upperRouter === self else {
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
    
    public func removeRoute(_ route: URLRouteName) {
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
    public func openRoute(_ route: URLRouteName, parameters: [String: Any]) -> Bool {
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
            
            if let webLinkRouteUrl = routeParser.routeUrl(from: URLRouter.webLink),
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
        if routeInterceptor.interceptSuccessfully(for: routeUrl) { return false }
        
        return handler(routeUrl, navigator)
    }
}

public func URLRouterLog<T>(_ message: T) {
#if DEBUG
    print("URLRouter Error ⚠️ :\(message)")
#endif
}

