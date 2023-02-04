//
//  RouteParser.swift
//  Router
//
//  Created by NeroXie on 2019/1/8.
//

import Foundation

public typealias URLRouteName = String

/// RouteURL is a data structure used to describe a routing entry.
/// Generally speaking, the URL data will be filled in RouteURL.
@objcMembers public class RouteURL: NSObject {
    
    public let scheme: String
    
    public let host: String
    
    public let path: String
    
    public private(set) var parameters: [String: Any]
    
    public var isWebLink: Bool { scheme.isWebScheme }
    
    public var combinedRoute: String { "\(scheme)://\(host)" }
    
    public var fullPath: String { "\(scheme)://\(host)\(path)" }
    
    public init(scheme: String, host: String, path: String, parameters: [String: Any]) {
        self.scheme = scheme
        self.host = host
        self.path = path
        self.parameters = parameters
    }
    
    public func resetParameters(_ parameters: [String: Any]) {
        self.parameters = parameters
    }
    
    public func mergingParameters(_ parameters: [String: Any]) {
        self.parameters = self.parameters.merging(parameters) { _, second in second }
    }
    
    public override var description: String { "URL full path: \(fullPath)\nURL parameters: \(parameters)" }
}

/// A protocol used to convert URL or String to RouteURL.
@objc public protocol URLRouteParserType: NSObjectProtocol {
    
    /// Default URL scheme.
    /// If the url string does not contain a scheme, the default scheme will be used.
    var defaultScheme: String { get }
    
    @objc(urlFromRoute:)
    /// Returns the URL through the route.
    /// - Parameter route: Specify a route
    /// - Returns: URL
    func url(from route: URLRouteName) -> URL?
    
    @objc(routeUrlFromRoute:params:)
    /// Returns the RouteURL through the route and custom parameters.
    /// - Parameters:
    ///   - route: Specify a route
    ///   - params: Those custom parameters that cannot be put in the URL.
    /// - Returns: RouteURL
    func routeUrl(from route: URLRouteName, params: [String: Any]) -> RouteURL?
}

public extension URLRouteParserType {
    
    func routeUrl(from route: URLRouteName, params: [String: Any] = [:]) -> RouteURL? {
        routeUrl(from: route, params: params)
    }
}

@objcMembers public class URLRouteParser: NSObject, URLRouteParserType {
    
    public let defaultScheme: String
    
    public required init(defaultScheme: String = "nn") {
        self.defaultScheme = defaultScheme.lowercased()
    }
    
    public func url(from routeString: String) -> URL? {
        var urlString = routeString
        if urlString.isEmpty { return nil }
        
        let schemeRange = (urlString as NSString).range(of: "://")
        if schemeRange.location == NSNotFound {
            urlString = defaultScheme + "://" + urlString
        } else if schemeRange.location == 0 {
            urlString = defaultScheme + urlString
        }
        
        let queryString = queryString(from: urlString)
        if queryString.isEmpty { return URL(string: urlString) }
        
        var components = URLComponents(string: urlString)
        components?.queryItems? = queryParameters(from: queryString).map { URLQueryItem(name: $0, value: $1) }
        return components?.url
    }
    
    public func routeUrl(from routeString: String, params: [String : Any]) -> RouteURL? {
        guard let url = url(from: routeString) else { return nil }
        
        var scheme = url.scheme?.lowercased().removingPercentEncoding ?? ""
        let host = url.host?.lowercased().removingPercentEncoding ?? ""
        let path = url.path.removingPercentEncoding ?? ""
        var parameters = parameters(with: url.query, exParameters: params)
        
        if scheme.isWebScheme {
            let tmpParams = params.filter { _, value in value is String } as! [String: String]
            parameters["url"] = url.appending(exQueries: tmpParams).absoluteString
        }
        
        if scheme == defaultScheme { scheme = "" }
        
        return RouteURL(scheme: scheme, host: host, path: path, parameters: parameters)
    }
    
    private func queryString(from url: String) -> String {
        let components = url.components(separatedBy: "?")
        if components.count < 2 { return "" }
        
        return components[1].components(separatedBy: "#")[0]
    }
    
    private func parameters(with urlQuery: String?, exParameters: [String: Any] = [:]) -> [String: Any] {
        guard let query = urlQuery else { return exParameters }
        
        let parameters: [String: Any] = queryParameters(from: query)
        return parameters.merging(exParameters) { _, second in second }
    }
    
    private func queryParameters(from urlQuery: String?) -> [String: String] {
        var pairs: [String: String] = [:]
        guard let urlQuery = urlQuery, !urlQuery.isEmpty else {
            return pairs
        }
        
        let delimiterSet = CharacterSet(charactersIn: "&;")
        let scanner = Scanner(string: urlQuery)
        while !scanner.isAtEnd {
            var pairString: NSString? = nil
            scanner.scanUpToCharacters(from: delimiterSet, into: &pairString)
            scanner.scanCharacters(from: delimiterSet, into: nil)
            if let kvPair = pairString?.components(separatedBy: "="),
               kvPair.count == 2,
               let key = kvPair[0].removingPercentEncoding,
               let value = kvPair[1].removingPercentEncoding {
                pairs[key] = value
            }
        }
        
        return pairs
    }
}

fileprivate extension String {
    
    var isWebScheme: Bool { lowercased() == "https" || lowercased() == "http" }
}

fileprivate extension URL {
    
    func appending(exQueries queries: [String: String]) -> URL {
        if queries.isEmpty { return self }
        
        let newQueryItems = queries.map { URLQueryItem(name: $0.key, value: $0.value) }
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        var oldQueryItems = components?.queryItems ?? []
        oldQueryItems.removeAll { queryItem in newQueryItems.contains { queryItem.name == $0.name } }
        components?.queryItems = oldQueryItems + newQueryItems
        
        return components?.url ?? self
    }
}


