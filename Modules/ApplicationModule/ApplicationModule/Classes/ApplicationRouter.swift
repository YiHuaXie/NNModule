//
//  ApplicationRouter.swift
//  ApplicationModule
//
//  Created by NeroXie on 2022/11/20.
//

import Foundation
import NNModule_swift
import ModuleServices

//class ApplicationRouter: NSObject, ModuleRouteService {
//    
//    static var implPriority: Int { 100 }
//    
//    private var router = URLRouter()
//    
//    required init() {
//        let configImpl = Module.service(of: ModuleConfigService.self)
//        let routeParser = URLRouteParser(defaultScheme: configImpl.appScheme)
//        router = URLRouter(routeParser: routeParser)
//    }
//    
//    var routeParser: URLRouteParserType { router.routeParser }
//    
//    var navigator: NavigatorType { router.navigator }
//    
//    var routeRedirector: URLRouteRedirector { router.routeRedirector }
//    
//    var routeInterceptor: URLRouteInterceptor { router.routeInterceptor }
//    
//    var upperRouter: URLRouterType? { router.upperRouter }
//    
//    func delayedRegisterRoute(_ route: URLRouteConvertible, handleRouteFactory: @escaping HandleRouteFactory) {
//        router.delayedRegisterRoute(route, handleRouteFactory: handleRouteFactory)
//    }
//    
//    func registerRoute(_ route: URLRouteConvertible, handleRouteFactory: @escaping HandleRouteFactory) {
//        router.registerRoute(route, handleRouteFactory: handleRouteFactory)
//    }
//    
//    func registerRoute(_ route: URLRouteConvertible, used subRouter: URLRouterType) {
//        guard subRouter.upperRouter === self else {
//            URLRouterLog("upper router for (\(subRouter)) is not \(self)")
//            return
//        }
//        
//        guard let routeUrl = router.routeParser.routeUrl(from: route) else {
//            URLRouterLog("route for (\(route)) is invalid")
//            return
//        }
//        
//        router.registerRoute(routeUrl.combinedRoute) { routeUrl, _ in
//            subRouter.openRoute(routeUrl.fullPath, parameters: routeUrl.parameters)
//        }
//    }
//    
//    func removeRoute(_ route: URLRouteConvertible) {
//        router.removeRoute(route)
//    }
//    
//    func removeAllRoutes() {
//        router.removeAllRoutes()
//    }
//    
//    func openRoute(_ route: URLRouteConvertible, parameters: [String : Any]) -> Bool {
//        router.openRoute(route, parameters: parameters)
//    }
//}
