//
//  RouteParser.swift
//  Router
//
//  Created by NeroXie on 2019/1/8.
//

import Foundation

public typealias RouteOriginalData = (route: URLRouteConvertible, params: [String: Any])

/// RouteURL is a data structure used to describe a routing entry.
/// Generally speaking, the URL data will be filled in RouteURL.
public struct RouteURL {

    public let scheme: String
    
    public let host: String
    
    public let path: String
    
    public let parameters: [String: Any]
    
    public let originalData: RouteOriginalData
    
    public var isWebLink: Bool { scheme.isWebScheme }

    public var combinedRoute: String { "\(scheme)://\(host)" }
    
    public var identifier: String { scheme + host + path }
}

/// A protocol used to convert URL or String to RouteURL.
public protocol URLRouteParserType {
    
    /// Default URL scheme.
    /// If the url string does not contain a scheme, the default scheme will be used.
    var defaultScheme: String { set get }
    
    /// Returns the URL through the route.
    /// - Parameter route: Specify a route
    /// - Returns: URL
    func url(from route: URLRouteConvertible) -> URL?
 
    /// Returns the RouteURL through the route and custom parameters.
    /// - Parameters:
    ///   - route: Specify a route
    ///   - params: Those custom parameters that cannot be put in the URL.
    /// - Returns: RouteURL
    func routeUrl(from route: URLRouteConvertible, params: [String: Any]) -> RouteURL?
}

public extension URLRouteParserType {

    func routeUrl(from route: URLRouteConvertible, params: [String: Any] = [:]) -> RouteURL? {
        routeUrl(from: route, params: params)
    }
}

public struct URLRouteParser: URLRouteParserType {
    
    public var defaultScheme: String
    
    public init(defaultScheme: String = "nn") {
        self.defaultScheme = defaultScheme.lowercased()
    }
    
    public func url(from route: URLRouteConvertible) -> URL? {
        let urlString = route.routeString
        guard urlString.count > 0 else { return nil }
        
        var newUrlString = urlString
        let nsUrlString = urlString as NSString
        let queryRange = nsUrlString.range(of: "?")
        if queryRange.location != NSNotFound, queryRange.length > 0 {
            var string = nsUrlString.substring(to: queryRange.location)
            let queryString = nsUrlString.substring(from: queryRange.location + 1)
            var index = 0
            dictionary(from: queryString).forEach { (key, value) in
                string += (index == 0 ? "?" : "&")
                string += "\(key)=\(urlEncode(from: value))"
                index += 1
            }
            
            newUrlString = string
        }
        
        let schemeRange = nsUrlString.range(of: "://")
        if schemeRange.length == 0 || queryRange.length > 0 && schemeRange.location > queryRange.location {
            newUrlString = defaultScheme + "://" + newUrlString
        } else if schemeRange.location == 0 {
            newUrlString = defaultScheme + newUrlString
        }
        
        return URL(string: newUrlString)
    }
  
    public func routeUrl(from route: URLRouteConvertible, params: [String : Any]) -> RouteURL? {
        guard let url = url(from: route) else { return nil }
        
        var scheme = url.scheme?.lowercased().removingPercentEncoding ?? ""
        let host = url.host?.lowercased().removingPercentEncoding ?? ""
        let path = url.path.removingPercentEncoding ?? ""
        
        var parameters = parameters(with: url.query, extraParameters: params)
        if scheme.isWebScheme { parameters["url"] = url.absoluteString }
        if scheme == defaultScheme { scheme = "" }
        
        return RouteURL(
            scheme: scheme,
            host: host,
            path: path,
            parameters: parameters,
            originalData: (route, params)
        )
    }
}

fileprivate extension URLRouteParser {
    
    func dictionary(from urlQuery: String) -> [String: String] {
        var pairs: [String: String] = [:]
        guard urlQuery.count > 0 else { return pairs }
        
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
    
    func parameters(with urlQuery: String?, extraParameters: [String: Any] = [:]) -> [String: Any] {
        guard let query = urlQuery else { return extraParameters }
        var parameters = extraParameters
        dictionary(from: query).forEach { parameters[$0] = $1.removingPercentEncoding }
        
        return parameters
    }
    
    func urlEncode(from urlString: String) -> String {
        var encodedString = ""
        let count = urlString.utf8.count + 1
        let result = UnsafeMutablePointer<Int8>.allocate(capacity: count)
        urlString.withCString { result.initialize(from: $0, count: count) }
        for i in 0..<strlen(result) {
            let c = String(format: "%c", result[i])
            if c == "." ||
                c == "-" ||
                c == "_" ||
                c == "~" ||
                (c >= "a" && c <= "z") ||
                (c >= "A" && c <= "Z") ||
                (c >= "0" && c <= "9") {
                encodedString += String(c)
            } else {
                encodedString += String(format: "%%%02X", result[i])
            }
        }
        
        return encodedString
    }
}

fileprivate extension String {
    
    var isWebScheme: Bool { lowercased() == "https" || lowercased() == "http" }
}
