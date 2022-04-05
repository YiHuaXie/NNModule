//
//  RouteConvertible.swift
//  Router
//
//  Created by NeroXie on 2019/1/10.
//

import Foundation

/// A type which can be converted to an URL string.
public protocol URLRouteConvertible {
    
    var routeString: String { get }
}

extension String: URLRouteConvertible {
    
    public var routeString: String { self }
}

extension URL: URLRouteConvertible {
    
    public var routeString: String { absoluteString }
}


