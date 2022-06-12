# URLRouter

## 简介

URLRouter 是一个基于对 URL 的解析，简单、方便、轻量的路由跳转方式。

URLRouter功能如下：
+ 路由注册与跳转
+ 路由嵌套+子路由懒加载实现路由的批量加载
+ 通过 URLRouteCombine 聚合多条路由减少整体路由条数
+ 路由重定向

## 使用

### 基础使用

```swift
let router =  URLRouter.default

// 修改默认scheme
router.routeParser.defaultScheme = "nn"
// or
router.routeParser = URLRouteParser(defaultScheme: "nn")

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

#### 1.子路由器和 URLRouteCombine 协议

URLRouter 的设计之初是一条路由对应一个 handler，且在项目启动阶段就将所有路由都注册完毕。当项目启动阶段就大量注册路由的话可能会增加启动耗时，为减少根路由器的路由表以及在启动阶段减少注册路由的次数，可以使用 URLRouter 作为子路由器与根路由器进行嵌套使用。

**子路由器**

使用方式如下：

```swift
// 定义根路由器
let router = URLRouter.default
// 创建子路由器并指定defaultScheme
let subRouter = URLRouter()
subRouter.routeParser.defaultScheme = router.routeParser.defaultScheme
// or
subRouter.routeParser = router.routeParser

// 延时注册路由，可减少在项目启动阶段注册的路由数量
subRouter.addLazyRegister {
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

// 将根路由器与子路由器进行嵌套
router.registerRoute("module", combiner: subRouter)

// 调用路由
router.openRoute("module/apage?id=a")
```

注意点：
+ URLRouter 的`addLazyRegister(_ register:)`用于延时注册路由可多次调用，在每次进行路由跳转前都会检查当前 router 是否有延时注册的路由条目
+ URLRouter 在层级上有跟路由器和子路由的层级概念，通常使用`URLRouter.default`作用根路由器，可以自定义根路由器
+ URLRouter 在使用子路由器的时候，需要保证子路由器的 routeParser 与根路由器的routeParser 是一致的

**URLRouteCombine**

子路由器的方式虽然可以减少项目初始过程中的路由注册条数，但不会减少整体的路由条数，使用 URLRouteCombine 协议来创建自定义的 Combiner 聚合处理多条路由，从而真正减少了整体的路由条数。

使用 URLRouteCombine 创建自定义的 Combiner，URLRouter 会使用 scheme+host 作为 key 来映射 Combiner，相同 scheme 和 host 的 url 都会匹配同一条路由，从而减少了整体的路由条数。自定义的 Combiner 使用方式如下：

```swift
// 自定义的Combiner
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

// 注册combiner
let webCombiner = WebCombiner()
router.registerRoute("https://nero.com", combiner: webCombiner)

// 调用路由
router.openRoute("https://nero.com/111")
```

注意点：

+ 在使用时建议一个 Combiner 处理相同的 scheme 和 host，方便直接从 path 开始判断

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

#### 3.路由重定向

URLRouter 支持对将要跳转路由进行重定向操作，重定向可以结合远程接口对路由进行升/降级。

```swift
// 重定向
let redirectRoutes: [String: String] = [
    "https://test.com/111": "module2/apage",
    "module2/bpage": "https://test.com/222"
]

URLRouter.default.updateRedirectRoutes(redirectRoutes)

// 跳转https://test.com/111会重定向到module2/apage
URLRouter.default.openRoute("https://test.com/111")
```

注意点：

+ 重定向路由表通过一个全局 map 进行管理，所以调用`updateRedirectRoutes(_ map: [String: String])`函数的 router 并不强制要求一定是根路由器

#### 4.获取最顶层的ViewController

```swift
let viewController: UIViewController? = Navigator.default.topViewController
```

## 要求

`iOS 10+`

## 安装

```ruby
pod 'NNModule-swift/URLRouter'
```

## Example

这里提供了一个[Example App](../Example_URLRouter/)，支持DeepLink。

1. 下载Example App
2. 运行`pod install`或者`pod update`
3. 编译并运行App
4. 打开Safari
5. 输入`nn://`即可打开Example App

## 其他功能

点击[这里](../README.md)可查看 NNModule-swift 的其他功能。