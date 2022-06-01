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

    init() {}
    
    func registerRoutes() {
        let router = URLRouter.default
        router.routeParser.defaultScheme = "nn"
        
        // 无效路由
        router.registerRoute("") { _, _ in true }
        router.registerRoute("%&") { _, _ in true }
        
        // register web
        router.registerRoute(router.webLink) { url, navigator in
            guard let urlString = url.parameters["url"] as? String, let url = URL(string: urlString) else {
                return false
            }

            navigator.push(SFSafariViewController(url: url))
            return true
        }

        router.registerRoute("https://www.baidu.com") { url, navigator in
            debugPrint("单独处理：https://www.baidu.com")
            print(url.parameters)

            return true
        }
        
        let webCombiner = WebCombiner()
        router.registerRoute("https://nero.com", combiner: webCombiner)
        router.registerRoute("https://nero.com", combiner: webCombiner)
        
        // register native
        let subRouter = URLRouter()
        subRouter.routeParser.defaultScheme = router.routeParser.defaultScheme
        subRouter.lazyRegister = {
            debugPrint("lazy load")
            
            $0.registerRoute("module/apage") { url, navigator in
                navigator.push(RouterAViewController(), animated: true)
                return true
            }
            
            $0.registerRoute("module/bpage") { url, navigator in
                print(url.parameters)
                navigator.present(RouterBViewController())
                return true
            }
            
            $0.registerRoute("module/cpage") { url, navigator in
                debugPrint("未找到CPage对应的页面")
                debugPrint(url.parameters)
                return true
            }
        }
        router.registerRoute("module", combiner: subRouter)

        // new scheme
        router.registerRoute("nero://aaa/sss/c") { url, navigator in
            print("test nero://aaa/sss/c success, params: \(url.parameters)")
            
            return true
        }
    }
    
}

struct WebCombiner: URLRouteCombine {
    
    func handleRoute(with routeUrl: RouteURL, navigator: NavigatorType) -> Bool {
        switch routeUrl.path {
        case "/111":
            debugPrint("/111")
        case "/222":
            debugPrint(routeUrl.parameters["url"] ?? "")
        default:
            debugPrint("`https://nero.com`下无对应Path：[\(routeUrl.path)]")
        }
        
        return true
    }
}
