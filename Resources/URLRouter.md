# URLRouter

## 简介

URLRouter 是一个基于对 URL 的解析，简单、方便、轻量的路由跳转方式。

## 使用

### 基础使用

```swift
let router =  URLRouter.default

// 修改默认scheme
router.routeParser.defaultScheme = "nn"

// 注册路由
router.registerRoute("module/apage") { url, navigator in
    debugPrint(url.parameters)
    navigator.push(RouterAViewController(), animated: true)
    
    return true
}

// 使用路由
URLRouter.default.openRoute("nn://module/apage?id=111&name=nero")
// or
URLRouter.default.openRoute("module/apage?id=111&name=nero")
// or
URLRouter.default.openRoute("module/apage", parameters: ["id": 111, "name": "nero"])
```
注意点：

+ 传入的路由需要符合URL的规范
+ 可以省略对默认的scheme声明
+ 支持在路由中传递对象数据
    ```swift
    URLRouter.default.openRoute("module/cpage?id=c", parameters: ["model": NSObject()])
    ```
    
### 其他使用

#### 1.使用 URLRouteCombine 或子路由器聚合处理多条路由

URLRouter 的设计初衷是一条路由对应一个 handler ，但是当项目中路由条数很多的时候，为减少根路由器的路由表，可以使用 URLRouteCombine 协议或者子路由器(URLRouter默认实现 URLRouteCombine 提供的接口)聚合处理多条路由。

Combiner (实现 URLRouteCombine 协议的实例或者 URLRouter 实例) 会使用 scheme+host 作为 key 进行存储，它只能处理含有相同的scheme 和 host 的 url，因此在使用时不建议一个 Combiner 处理不同的 scheme 和 host 。

**使用子路由器**

URLRouter 可作为子路由器与根路由器进行嵌套使用，子路由器使用方式如下：

```swift
// 创建子路由器并指定defaultScheme
let subRouter = URLRouter()
subRouter.routeParser.defaultScheme = router.routeParser.defaultScheme

// 使用lazyRegister对路由进行懒加载，可减少在项目启动阶段注册的路由数量
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

// 使用scheme+host注册子路由器
router.registerRoute("module", combiner: subRouter)

// 调用路由
URLRouter.default.openRoute("module/apage?id=a")
```

**使用 URLRouteCombine**

你可以使用 URLRouteCombine 创建自定义的Combiner来批量处理路由，URLRouteCombine使用方式如下：

```swift
// 自定义的Combiner
class WebCombiner: URLRouteCombine {
    
    init() {}
    
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

// 注册combiner
let webCombiner = WebCombiner()
router.registerRoute("https://nero.com", combiner: webCombiner)

// 调用路由
URLRouter.default.openRoute("https://nero.com/111")
```

#### 2.对Http/Https的支持

URLRouter 提供了一个 webLink 的路由名支持对 Http/Https 链接的统一处理，也可以通过注册指定链接优先处理该指定链接。

```swift
let router =  URLRouter.default
// 统一处理
router.registerRoute(router.webLink) { url, navigator in
    guard let urlString = url.parameters["url"] as? String, let url = URL(string: urlString) else {
        return false
    }

    navigator.push(SFSafariViewController(url: url))
    return true
}

// 单独处理某个链接
router.registerRoute("https://www.baidu.com") { url, navigator in
    print(url.parameters)

    return true
}
```

#### 3.获取最顶层的ViewController

```swift
let viewController: UIViewController? = Navigator.default.topViewController
```

## 要求

`iOS 10+`

## 安装

```ruby
pod NNModule/URLRouter
```

## Example

这里提供了一个[Example App](../Example_URLRouter/)，支持DeepLink。

1. 编译并安装Example App
2. 打开Safari
3. 输入`nn://`即可打开Example App

## 其他功能

点击[这里](../README.md)可查看NNModule的其他功能。