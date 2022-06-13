# URLRouter

## 简介

URLRouter 是一个基于对 URL 的解析，简单、方便、轻量的路由跳转方式。

URLRouter功能如下：
+ 路由注册与跳转
+ 路由懒加载（延时注册）
+ 路由聚合
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

#### 1. 路由延时注册

URLRouter 的设计之初是在项目启动阶段就将所有路由都注册完毕。当项目启动阶段就大量注册路由的话可能会增加启动耗时，可以使用延时注册的方式优化在启动阶段大量注册路由。

URLRouter 通过`addLazyRegister(_ register:)`函数先保存需要延时注册的路由，在进行路由跳转时先注册这些需要延时注册的路由。使用方式如下：

```swift
let router = URLRouter.default
router.addLazyRegister {
    $0.registerRoute("module/apage") { url, navigator in
        navigator.push(RouterAViewController(), animated: true)
        return true
    }
    
    $0.registerRoute("module/bpage") { url, navigator in
        print(url.parameters)
        navigator.present(RouterBViewController())
        return true
    } 
}
```

#### 2. 路由聚合

URLRouter 中每一条路由对应一个 handler，随着项目的迭代，路由表会越来越大，在网络工程中，我们可以会将下一跳地址相同的路由条目进行聚合来减少单个路由器的路由表大小。

URLRouter 通过`registerRoute(_ route: URLRouteConvertible, combiner: URLRouteCombine)`函数实现路由聚合。URLRouter 将 route 的 scheme 和 host 作为 key 来映射 combiner。路由跳转时，相同 scheme 和 host 的 url 都会匹配同一条路由，并交给对应的 combiner 转发。

combiner 需要遵循`URLRouteCombine`协议，URLRouter 类本身已经遵循`URLRouteCombine`协议，因此可以直接作为 combiner 使用。使用 URLRouter 作为 combiner (即子路由器) 时需要保证子路由器的 routeParser 与根路由器的routeParser 是一致的。

**URLRouter 作为 combiner**

方式如下：

```swift
// 创建根路由器
let router = URLRouter.default
// 创建子路由器
let subRouter = URLRouter()
subRouter.routeParser = router.routeParser
// 子路由器延时注册路由
subRouter.addLazyRegister {
    $0.registerRoute("nn://module/apage") { url, navigator in
        navigator.push(RouterAViewController(), animated: true)
        return true
    }
    
    $0.registerRoute("nn://module/bpage") { url, navigator in
        print(url.parameters)
        navigator.present(RouterBViewController())
        return true
    }
    
    $0.registerRoute("nn://module2/apage") { url, navigator in
        navigator.push(RouterAViewController(), animated: true)
        return true
    }
}

// 子路由器与根路由器嵌套，所有以nn://module和nn://module2开头的url都会被发送到subRouter中处理
router.registerRoute("module", combiner: subRouter)
router.registerRoute("module2", combiner: subRouter)

// 调用路由
router.openRoute("module/apage?id=a")
```

**自定义 combiner**

使用方式如下：

```swift
// 自定义的Combiner
struct WebCombiner: URLRouteCombine {
    
    init () {}
    
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

#### 3.路由重定向

URLRouter 支持对将要跳转路由进行重定向操作，重定向可以结合远程接口对路由进行升/降级。重定向路由表通过一个全局 map 进行管理，所以调用`updateRedirectRoutes(_ map: [String: String])`函数的 router 并不强制要求一定是根路由器。

使用方式如下：

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

#### 4.对Http/Https的支持

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

#### 5.获取最顶层的ViewController

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