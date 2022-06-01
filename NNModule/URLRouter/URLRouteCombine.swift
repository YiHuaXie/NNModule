//
//  URLRouteCombine.swift
//  Router
//
//  Created by NeroXie on 2019/5/5.
//

import Foundation

/// Provides a combiner that can handle multiple routes
public protocol URLRouteCombine {
    
    func handleRoute(with routeUrl: RouteURL, navigator: NavigatorType) -> Bool
}
