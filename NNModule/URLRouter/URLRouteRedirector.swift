//
//  URLRouteRedirector.swift
//  NNModule-swift
//
//  Created by NeroXie on 2022/11/9.
//

import Foundation

public typealias RouteRedirectData = (route: URLRouteConvertible, params: [String: Any])

public class URLRouteRedirector {
    
    private var routeMap: [String: String] = [:]
    
    private var routeParser: URLRouteParserType
    
    public init(with routeParser: URLRouteParserType = URLRouteParser()) {
        self.routeParser = routeParser
    }
    
    /// Updates redirect route map.
    /// - Parameter routeMap: A redirect route map
    public func updateRedirectRoutes(_ routeMap: [String: String]) {
        var map: [String: String] = [:]
        routeMap.forEach { if let key = routeParser.routeUrl(from: $0)?.fullPath { map[key] = $1 } }
        self.routeMap = self.routeMap.merging(map) { _, second in second }
    }
    
    /// Resets redirect route map.
    /// - Parameter routeMap: A redirect route map
    public func resetRedirectRoutes(_ routeMap: [String: String]) {
        var map: [String: String] = [:]
        routeMap.forEach { if let key = routeParser.routeUrl(from: $0)?.fullPath { map[key] = $1 } }
        self.routeMap = routeMap
    }
    
    /// Gets the redirection data of the route.
    /// - Parameter routeUrl: Original route data
    /// - Returns: Redirection data of the route
    public func routeRedirectData(from routeUrl: RouteURL) -> RouteRedirectData? {
        guard let redirectRoute = routeMap[routeUrl.fullPath] else { return nil }
        
        var redirectParams = routeUrl.parameters
        if routeUrl.isWebLink { redirectParams.removeValue(forKey: "url") }
        
        return (redirectRoute, redirectParams)
    }
}
