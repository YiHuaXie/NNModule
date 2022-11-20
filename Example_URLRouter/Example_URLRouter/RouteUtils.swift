//
//  RouteUtils.swift
//  Example_URLRouter
//
//  Created by NeroXie on 2021/8/15.
//

import Foundation
import NNModule_swift
import SafariServices

class RouteUtils {
    
    private static let router = URLRouter.default
    
    private static var subRouter = URLRouter(with: router)
    
    init() {}
    
    static func setup() {
        let routeParser = URLRouteParser(defaultScheme: "nn")
        URLRouter.default = URLRouter(routeParser: routeParser)

        // invalid routes
        router.registerRoute("") { _, _ in true }
        router.registerRoute("%&") { _, _ in true }
        
        urlTest()
        htmlTest()
        nativeTest()
        schemeTest()
        interceptorTest()
        redirectTest()
    }
    
    private static func urlTest() {
        let urlStrings: [String] = [
            "",
            "%#",
            "?#",
            "id=1&name=你.好_啊-啊~",
            "id=1&name=%E4%BD%A0.%E5%A5%BD_%E5%95%8A-%E5%95%8A~",
            "module",
            "module/main",
            "module/main?",
            "module/main?#click",
            "module/main?id=1",
            "module/main?id=1#click",
            "://module/main?id=1#click",
            "app://module/main?id=1#click",
            "app://module/main/春节",
            "app://module/main/春节?id=1&name=你.好_啊-啊~",
            "app://module/main/%E6%98%A5%E8%8A%82?id=1&name=你.好_啊-啊~",
            "app://module/main/%E6%98%A5%E8%8A%82?id=1&name=%E4%BD%A0.%E5%A5%BD_%E5%95%8A-%E5%95%8A~#click",
        ]
        
        for urlString in urlStrings {
            print("============== Test case: \(urlString) ==============")
            print("URL = \(URL(string: urlString))")
            print("URL form route parser = \(URLRouter.default.routeParser.url(from: urlString))")
            print("RouteURL = \(URLRouter.default.routeParser.routeUrl(from: urlString))")
            print("=====================================================")
        }
    }
    
    private static func htmlTest() {
        router.registerRoute(router.webLink) { routeUrl, navigator in
            guard let urlString = routeUrl.parameters["url"] as? String, let url = URL(string: urlString) else {
                return false
            }
            
            navigator.push(SFSafariViewController(url: url))
            return true
        }
        
        router.registerRoute("https://www.baidu.com") { routeUrl, navigator in
            let url = routeUrl.parameters["url"] ?? ""
            debugPrint("handle a specified route：\(url)")
            
            return true
        }
        
        router.registerRoute("https://nero.com") { routeUrl, navigator in
            switch routeUrl.path {
            case "/111":
                let url = routeUrl.parameters["url"] ?? ""
                debugPrint("open url: \(url)")
                return true
            default:
                debugPrint("https://nero.com\(routeUrl.path) is invalid.")
                return false
            }
        }
    }
    
    private static func nativeTest() {
        router.registerRoute("module2/111") { routeUrl, navigator in
            debugPrint("route url: \(routeUrl)")
            return true
        }
        
        subRouter = URLRouter(with: router)
        subRouter.delayedRegisterRoute("module") { routeUrl, navigator in
            switch routeUrl.path {
            case "", "/apage":
                debugPrint(routeUrl.parameters)
                navigator.push(RouterAViewController(), animated: true)
                return true
            case "/bpage":
                debugPrint(routeUrl.parameters)
                navigator.present(RouterBViewController())
                return true
            default: return false
            }
        }
        
        router.registerRoute("module", used: subRouter)
    }
    
    private static func schemeTest() {
        router.registerRoute("nero://aaa/sss/c") { url, navigator in
            debugPrint("test \(url.fullPath) success, params: \(url.parameters)")
            return true
        }
    }
    
    private static func interceptorTest() {
        router.registerRoute("module3/main") { routeUrl, navigator in
            debugPrint(routeUrl.parameters)
            navigator.push(RouterAViewController())
            return true
        }
        
        router.registerRoute("module3/apage") { routeUrl, navigator in
            debugPrint(routeUrl.parameters)
            navigator.present(RouterBViewController())
            return true
        }
        
        router.routeInterceptor.append(LoginAction())
        router.routeInterceptor.append(PermissionAction())
        router.routeInterceptor.insert(LogAction(), at: 0)
        router.routeInterceptor.append(URLRouteInterceptor.Action(specifiedRoutes: ["%&"]) { _ in .next })
        router.routeInterceptor.append(URLRouteInterceptor.Action(specifiedRoute: "module3/main") {
            debugPrint("interception action: \($0.fullPath)")
            return .next
        })
    }
    
    private static func redirectTest() {
        let routeMap = ["https://redirect.com/main" : "redirect/main", "redirect/apage" : "https://redirect.com/apage"]
        router.routeRedirector.updateRedirectRoutes(routeMap)
        router.registerRoute("https://redirect.com") { routeUrl, navigator in
            switch routeUrl.path {
            case "/main", "/apage":
                debugPrint(routeUrl)
                return true
            default:
                return false
            }
        }
        
        router.registerRoute("redirect") { routeUrl, navigator in
            switch routeUrl.path {
            case "/main":
                debugPrint(routeUrl.parameters)
                navigator.push(RouterAViewController())
                return true
            case "/apage":
                debugPrint(routeUrl.parameters)
                navigator.present(RouterBViewController())
                return true
            default:
                return false
            }
        }
    }
}

class LogAction: URLRouteInterceptionAction {
    
    var specifiedRoutes: [URLRouteConvertible]? { nil }

    func interceptRoute(for routeUrl: RouteURL) -> URLRouteInterceptionResult {
        print("\n================ Test case ================")
        print("route: \(routeUrl.fullPath), paramters: \(routeUrl.parameters)")
        print("===========================================\n")
        return .next
    }
}

class LoginAction: URLRouteInterceptionAction {
    
    var specifiedRoutes: [URLRouteConvertible]? { ["module3/apage", "module3/main"] }

    func interceptRoute(for routeUrl: RouteURL) -> URLRouteInterceptionResult {
        if routeUrl.parameters["uid"] == nil {
            let alert = UIAlertController(title: "Login error", message: "no uid", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            UIApplication.topViewController?.present(alert, animated: true)
            
            return .reject
        }
        
        return .next
    }
}

class PermissionAction: URLRouteInterceptionAction {
    
    var specifiedRoutes: [URLRouteConvertible]? { ["module3"] }
    
    func interceptRoute(for routeUrl: RouteURL) -> URLRouteInterceptionResult {
        if routeUrl.path == "/apage", routeUrl.parameters["permission"] == nil {
            let alert = UIAlertController(title: "Permission error", message: "no permission", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            UIApplication.topViewController?.present(alert, animated: true)
            
            return .reject
        }
        
        return .next
    }
}
