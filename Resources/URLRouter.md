# URLRouter

## 简介

URLRouter 是一个基于对 URL 的解析，简单、方便、轻量的路由跳转方式。提供的功能如下：
+ 路由注册与跳转
+ 路由延时注册
+ 路由拦截
+ 路由重定向
+ router 嵌套

## 使用

### 使用前

在使用前先介绍下 URLRouter 中的相关概念：

+ `URLRouterType`: 定义 router 的接口，`URLRouter` 为默认实现
+ `URLRouteParserType`: 定义 URL 解析的接口，`URLRouteParser` 为默认实现
+ `NavigatorType`: 定义导航的接口，`Navigator` 为默认实现
+ `URLRouteRedirector`: 路由重定向器
+ `URLRouteInterceptor`: 路由拦截器
+ `URLRouteInterceptionAction`: 路由拦截行为，一个路由拦截器会有多个 action，`URLRouteInterceptor.Action` 为默认实现
+ `RouteURL`: 描述路由的数据对象

### 创建 router

```swift
let routeParser = URLRouteParser(defaultScheme: "your app scheme")
URLRouter.default = URLRouter(routeParser: routeParser, navigator: Navigator())
// or
let router = URLRouter(routeParser: routeParser, navigator: Navigator())
```

URLRouter 提供了一个默认的 router `URLRouter.default`，但只是方便作为根 router 而存在，可以在项目初始化时重新定义，也可以根据 `URLRouterType` 自定义一个 router 类。

### 路由注册与跳转

URLRouter 支持单条路由、聚合路由的注册。

路由注册：

```swift
let router = URLRouter.default

// 注册单条路由
router.registerRoute("module/apage") { routeUrl, navigator in
    print(routeUrl.parameters)
    navigator.push(AViewController(), animated: true)
    
    return true
}

// 注册聚合路由
router.registerRoute("module") { routeUrl, navigator in
    print(routeUrl.parameters)
    switch routeUrl.path {
    case "/apage":
        navigator.push(AViewController(), animated: true)
        return true
    case "/bpage":
        navigator.push(BViewController(), animated: true)
        return true
    default:
        return false
    }
}
```

路由跳转的多种写法：

```swift
router.openRoute("nn://module/apage?id=111&name=nero")
// or
router.openRoute("://module/apage?id=111&name=nero")
// or
router.openRoute("module/apage", parameters: ["id": 111, "name": "nero"])
```

注意事项：

+ 传入的路由需要符合 URL 的规范，可以是 String 类型也可以是 URL 类型
+ 可以省略对默认的 scheme 声明，scheme 和 host 不区分大小写，path 区分大小写
+ 若有单条路由的 handler 则会优先匹配，否则就会匹配聚合路由的 handler，URLRouter 使用 `scheme://host` 做为聚合路由
+ 聚合路由可以减少 router 中的路由表大小，在定义路由时处于同一业务模块的路由建议使用同一个 host
+ 跳转路由时传递传递对象类型的数据
+ 跳转路由时，parameters 和 URL 的 query存在相同键时，使用 parameters 中的值

### 路由延时注册

URLRouter 支持路由的延时注册，在跳转路由时会先注册所有延时注册的路由。

```swift
let router = URLRouter.default
router.delayedRegisterRoute("module/apage") { routeUrl, navigator in
    navigator.push(AViewController(), animated: true)
    return true
}
```

### 路由重定向

URLRouter 支持对将要跳转的路由进行重定向操作，重定向可以结合远程接口对路由进行升/降级。

```swift
// 重定向表
let routeMap = ["https://redirect.com/main" : "redirect/main"]
URLRouter.default.routeRedirector.updateRedirectRoutes(routeMap)

// 跳转 https://redirect.com/main 会重定向到 redirect/main
URLRouter.default.openRoute("https://redirect.com/main")
```

### 路由拦截

拦截器的作用主要是对匹配到的路由进行拦截，之后根据开发者的规则来判定拦截与否，若拦截成功，那么路由对应的 handler 则不会执行。URLRouter 中使用 `URLRouteInterceptor` 类拦截路由，`URLRouteInterceptor`包含多个拦截 Action `URLRouteInterceptionAction`，每个拦截 Action 中开发者可以自定义拦截规则。

一个路由可以匹配多个拦截 Action，只要有一个拦截 Action 拦截成功，则视为拦截成功。拦截 Action 是有顺序的，通常先添加的 Action 会先调用，也可以使用 `URLRouteInterceptor` 的 `func insert(_ action: URLRouteInterceptionAction, at i: Int)` 函数修改顺序。

`URLRouteInterceptor` 定义：

```swift
public class URLRouteInterceptor {
    // 插入 Action
    public func insert(_ action: URLRouteInterceptionAction, at i: Int) 
    // 添加 Action
    public func append(_ action: URLRouteInterceptionAction) 
    // 删除 Action
    public func remove(_ action: URLRouteInterceptionAction)
}
```

`URLRouteInterceptionAction` 定义：

```swift
public protocol URLRouteInterceptionAction: AnyObject {
    // 指定的路由，返回空数组或 nil 时，该 action 匹配所有路由
    var specifiedRoutes: [URLRouteConvertible]? { get }
    // 定义拦截规则
    func interceptRoute(for routeUrl: RouteURL) -> URLRouteInterceptionResult
}
```

使用默认拦截 Action：

```swift
let action = URLRouteInterceptor.Action(specifiedRoutes: ["module"]) {
    // 定义拦截规则
}
// 添加拦截 Action
URLRouter.default.routeInterceptor.append(action)
```
使用自定义拦截 Action：

```swift
// 定义拦截 Action
class PermissionAction: URLRouteInterceptionAction {
    
    var specifiedRoutes: [URLRouteConvertible]? { ["module"] }
    
    func interceptRoute(for routeUrl: RouteURL) -> URLRouteInterceptionResult {
        guard LoginManager.shared.isLogin else {
            // 跳转登录
            URLRouter.default.openRoute("login/main")
            return .reject
        }
        
        var parameters = routeUrl.parameters
        if parameters["permission"] == nil {
            parameters["permission"] = 1
            // 重置路由参数
            return .reset(parameters: parameters)
        }
        
        return .next
    }
}

// 插入拦截 Action
URLRouter.default.routeInterceptor.insert(PermissionAction(), at: 0)
```

### router 嵌套

URLRouter 中的 router 可以分成全局 router（根 router ）和模块内 router（子 router ）。在组件化开发的场景下，开发者可以为每个业务模块单独创建一个 router 并与全局 router 进行嵌套，模块中的路由跳转（包括外部路由）均使用该 router。

在进行 router 嵌套后，根 router 下的所有子 router 均使用根 router 的 URL 解析器、导航、重定向器以及拦截器进行路由的解析与跳转。另外使用 router 嵌套结合子 router 延时注册路由的方式可以真正做到按模块加载路由的效果。

使用子 router：

```swift
// 1. 创建子 router

// 根 router
let router = URLRouter.default
// 通过根 router 创建A模块子 router
let subRouterA = URLRouter(with: router)
subRouterA.registerRoute("amodule/main") { routeUrl, navigator in
    navigator.push(AViewController())
    return true
}
// 通过根 router 创建B模块子 router 
let subRouterB = URLRouter(with: router)
subRouter2.registerRoute("bmodule/main") { routeUrl, navigator in
    navigator.present(BViewController())
    return true
}

// 2.根 router 添加子 router 所处理的路由条目

// host 为 amodule 的路由都会由 subRouterA 处理
router.registerRoute("amodule", used: subRouterA)
// host 为 bmodule 的路由都会由 subRouterB 处理
router.registerRoute("bmodule", used: subRouterB)

// 3. 使用子 router 跳转

// A模块页面中跳转B模块页面
subRouterA.openRoute("bmodule/main?id=123")
// or
router.openRoute("bmodule/main?id=123")
```

注意事项：

+ 使用 URLRouter 类作为子 router 必须使用 `URLRouter.init(with: rootRouter)` 函数进行初始化，子 router 匹配不了的路由会交给它的 `upperRouter` 去转发，这里的 `upperRouter` 一般就是根 router
+ `upperRouter` 使用`registerRoute(_ route: URLRouteConvertible, used subRouter: URLRouterType)` 函数提前绑定路由与子 router 的映射关系，以便跳转时能找到正确的子 router
+ 注册子 router 的使用路由为聚合路由即 `scheme://host`，如注册的路由中携带 path 将会被忽略

### 其他

#### 对Http/Https的支持

URLRouter 提供了一个 webLink 的路由名支持对 Http/Https 链接的统一处理，也可以通过注册指定链接优先处理该指定链接。

```swift
let router =  URLRouter.default
router.registerRoute(router.webLink) { routeUrl, navigator in
    // 统一处理
}

router.registerRoute("https://www.baidu.com") { url, navigator in
    // 单独处理某个链接
}
```

#### 获取最顶层的ViewController

```swift
let viewController: UIViewController? = UIApplication.topViewController
```

#### 关于定制

URLRouter 是面向协议进行开发的，开发者可以根据`URLRouteType`、`URLRouteParserType`以及`NavigatorType`提供的接口自定义规则进行实现。

在基于 `URLRouteType` 自定义 router 尤其是根 router 时，除了路由注册与跳转的功能以外其他功能都是非必须功能可不实现，`URLRouteType` 的 extension 默认实现中会通过断言抛出异常来提示开发者使用了未实现的功能。

## 要求

`iOS 10+`

## 安装

```ruby
pod 'NNModule-swift/URLRouter'
```

## Example

这里提供了一个[Example App](../Example_URLRouter/)，支持DeepLink。

1. 下载 Example App
2. 运行 `pod install` 或者 `pod update`
3. 编译并运行 App
4. 打开 Safari
5. 输入`nn://`即可打开 Example App

## 其他功能

点击[这里](../README.md)可查看 NNModule-swift 的其他功能。