//
//  URLRouteRedirector.swift
//  NNModule-swift
//
//  Created by NeroXie on 2022/11/9.
//

import Foundation

public typealias RouteRedirectData = (route: URLRouteName, params: [String: Any])

@objcMembers public class URLRouteRedirector: NSObject {
    
    private var routeMap: [URLRouteName: String] = [:]
    
    private var routeParser: URLRouteParserType
    
    @objc(initWithRouteParser:)
    public init(with routeParser: URLRouteParserType) {
        self.routeParser = routeParser
    }
    
    /// Updates redirect route map.
    /// - Parameter routeMap: A redirect route map
    public func updateRedirectRoutes(_ routeMap: [String: String]) {
        var map: [URLRouteName: String] = [:]
        routeMap.forEach { if let key = routeParser.routeUrl(from: $0)?.fullPath { map[key] = $1 } }
        self.routeMap = self.routeMap.merging(map) { _, second in second }
    }
    
    /// Resets redirect route map.
    /// - Parameter routeMap: A redirect route map
    public func resetRedirectRoutes(_ routeMap: [String: String]) {
        var map: [String: String] = [:]
        routeMap.forEach { if let key = routeParser.routeUrl(from: $0)?.fullPath {  map[key] = $1 } }
        self.routeMap = map
    }
    
    /// Gets the redirection data of the route.
    /// - Parameter routeUrl: Original route data
    /// - Returns: Redirection data of the route
    public func routeRedirectData(from routeUrl: RouteURL) -> RouteRedirectData? {
        guard let redirectRoute = routeMap[routeUrl.fullPath] else { return nil }
        
        var redirectParams = routeUrl.parameters
        // delete the url if the original route is a web link.
        // The url added by URLRouter.
        if routeUrl.isWebLink { redirectParams.removeValue(forKey: "url") }
        
        return (redirectRoute, redirectParams)
    }
    
    @available(swift, obsoleted: 3.0, message: "Only used in Objective-C")
    /// Gets the redirection data of the route.
    /// - Parameters:
    ///   - routeUrl: Original route data
    ///   - redirectRoute: The redirect route.
    ///   - redirectParams: The parameters of the redirect route.
    public func routeRedirectDataFromRouteUrl(
        _ routeUrl: RouteURL,
        redirectRoute: UnsafeMutablePointer<NSString>,
        redirectParams: UnsafeMutablePointer<NSDictionary>
    ) {
        guard let data = routeRedirectData(from: routeUrl) else { return }
        
        redirectRoute.pointee = data.route as NSString
        redirectParams.pointee = data.params as NSDictionary
    }
}
