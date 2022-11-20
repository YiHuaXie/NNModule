# NNModule-swift

<!--[![CI Status](https://img.shields.io/travis/NeroXie/NNModule.svg?style=flat)](https://travis-ci.org/NeroXie/NNModule)-->
[![Version](https://img.shields.io/cocoapods/v/NNModule-swift.svg?style=flat)](https://cocoapods.org/pods/NNModule-swift)
[![License](https://img.shields.io/cocoapods/l/NNModule-swift.svg?style=flat)](https://cocoapods.org/pods/NNModule-swift)
[![Platform](https://img.shields.io/cocoapods/p/NNModule-swift.svg?style=flat)](https://cocoapods.org/pods/NNModule-swift)

## 简介

NNModule-swift 用于 Swift 项目的模块管理，主要用于业务模块之间的解耦（以协议的方式进行解耦）， 希望通过 NNModule 向大家提供一种思路，对遇到类似问题的同学能有所启发。

NNModule-swift 提供的功能如下：

+ 组件化管理器：[ModuleManager](./Resources/ModuleManager.md)
+ 路由：[URLRouter](./Resources/URLRouter.md)
+ 事件传输：[EventTransfer](./Resources/EventTransfer.md)
+ 带黏连值的 Notification：[StickyNotification](./Resources/StickyNotification.md)

## 使用

在使用 NNModule-swift 之前建议阅读[ModuleManager设计介绍](./Resources/ModuleManager.md)来理解服务解耦以及如何注册服务。另外提供了一个[Example App](./Example_ModuleManager/)来方便更好地理解。

### 主工程（壳工程）改造

使用以下代码替换`AppDelegate`文件中的代码：

```swift
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    override init() {
        super.init()
        // Ensure that `ModuleManager.shared` is created first
        _ = ModuleManager.shared
    }
    
    func application(
        _ application: UIApplication,
        willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        ModuleManager.shared.application(application, willFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        ModuleManager.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override func forwardingTarget(for aSelector: Selector!) -> Any? { Module.applicationService }
    
    override func responds(to aSelector: Selector!) -> Bool {
        super.responds(to: aSelector) || Module.applicationService.responds(to: aSelector)
    }
}
```

### 使用路由服务

`ModuleRouteService` 提供了路由功能，具体定义可以查看[ModuleRouteService](./NNModule/ModuleManager/Services/ModuleRouteService.swift)。
`ModuleRouteService`的 Impl 类是内部的 URLRouter，路由完整的使用方式可以查看[URLRouter](./Resources/URLRouter.md)。

#### 注册路由

在你需要的业务组件创建 `Module.Awake`（用于为功能类服务添加注册类服务）分类并添加类方法，在类方法中完成路由的注册。这里要注意添加的类方法必须是带 `@objc` 标记的，至于方法名字可以随意写，甚至你不怕项目警告多的话可以使用同一个函数名比如 awake（即使存在同名函数的类方法在调用过程中也不会被覆盖），具体原因可以阅读[方案2：调用指定类方法列表中的所有方法](./Resources/ModuleManager.md)。

```swift
extension Module.Awake {
    
    @objc static func aModuleAwake() {
        Module.routeService.registerRoute("A2Page") { url, navigator in
            print(url.parameters)
            navigator.push(A2ViewController())
            
            return true
        }
    }
}
```

#### 调用路由

```swift
Module.routeService.openRoute("A2Page", parameters: ["model": self])
```

### 使用 TabBar 服务

`ModuleTabService` 用于获取项目中 TabBar 相关的功能，具体定义可以查看[ModuleTabService](./NNModule/ModuleManager/Services/ModuleTabService.swift)。

#### 指定 TabBarController 的类型

```swift
extension Module.Awake {
    
    @objc static func applicationModule() {
        if let cls = NSClassFromString("TabBarController.TabBarController"),
           let tabBarType = cls as? UITabBarController.Type {
            Module.tabService.tabBarControllerType = tabBarType
        }
    }
}
```

#### 注册 TabBarItem

`RegisterTabItemService` 提供为 `ModuleTabService` 注册 tabBarItem 的功能，具体定义可以查看[RegisterTabItemService](./NNModule/ModuleManager/Services/ModuleTabService.swift)。

注册 tabBar item 示例代码如下：

```swift
extension Module.Awake {
    
    @objc static func bModuleAwake() {
        //  为 tabService 添加 BModuleImpl 
        Module.tabService.addRegister(BModuleImpl.self)
        Module.launchTaskService.addRegister(ModuleLaunchTaskTest.self)
    }
}

class BModuleImpl: NSObject, RegisterTabItemService {
    
    func registerTabBarItems() -> [TabBarItemMeta] {
        let bundle = resourceBundle(of: "BModule")
        let nav = UINavigationController(rootViewController: UserViewController())
        let image = UIImage(named: "tabbar_user_normal", in: bundle, compatibleWith: nil)
        let selectedImage = UIImage(named: "tabbar_user_normal", in: bundle, compatibleWith: nil)
        nav.tabBarItem = ESTabBarItem(NormalTabBarItemContentView(), title: "user", image: image, selectedImage: selectedImage)
        let meta = TabBarItemMeta(viewController: nav, tabIndex: 2)
        
        return [meta]
    }
    
    override required init() {
        super.init()    
    }
}
```

### 其他功能类服务

除了上面提到的基础服务外还有`ModuleNotificationService`（通知）、、`ModuleLaunchTaskService`(启动任务)，用法和上面类似这里就不一一介绍了。

其他可以查看

+ [ModuleNotificationService](./NNModule/ModuleManager/Services/ModuleNotificationService.swift)
+ [ModuleLaunchTaskService](./NNModule/ModuleManager/Services/ModuleLaunchTaskService.swift)

### 创建自定义的服务

项目中除了上面提到的基础服务外，还有很多关于业务的服务，这些是要我们自己创建并注册的。 以登录为例演示如何创建自定义的服务，这里的服务指的是功能类服务。

**定义LoginService用于提供登录相关的功能**

```swift
// Login service
public protocol LoginService: ModuleFunctionalService {
    
    /// the main viewController of LoginModule
    var loginMain: UIViewController { get }
    
    var isLogin: Bool { get }

    func logout()
}

/// The notification of Login
public extension Notification.Name {
    
    static var didLoginSuccess: Notification.Name { .init("didLoginSuccess") }
    
    static var didLogoutSuccess: Notification.Name { .init("didLogoutSuccess") }
}
```

我们会使用一个组件存放所有需要跨模块通信的服务，所有的业务组件都会依赖这个组件。

**定义LoginService impl**

一般登录相关的逻辑与相关页面我们会放在一个叫 LoginModule的组件中，其中就包含了`LoginService`的Impl，我们就叫做`LoginManager`吧。

`LoginManager`的实现如下：

```swift
extension Module.RegisterService {
    
    @objc static func registerLoginService() {
        Module.register(service: LoginService.self, used: LoginManager.self)
    }
}

internal final class LoginManager: LoginService {

    static let shared = LoginManager()
    
    static var implInstance: ModuleBasicService { shared }
    
    var isLogin: Bool = false
    
    required init() {}
    
    var loginMain: UIViewController {
        UINavigationController(rootViewController: LoginViewController())
    }
    
    func logout() { updateLoginStatus(false) }
    
    private func updateLoginStatus(_ loginStatus: Bool) {
        isLogin = loginStatus
        let notification: Notification.Name = loginStatus ? .didLoginSuccess : .didLogoutSuccess
        Module.notificationService.post(name: notification)
    }
}
```

### 替换已有服务的Impl

由于`ModuleApplicationService`通常作为第一个被加载的service，其默认Impl内没有任何逻辑，而在项目中该服务的Impl是一定需要替换，所以我们就以`ModuleApplicationService`作为例子来演示如何替换已有服务的Impl。

我们可以创建一个 ApplicationModule 的组件，该组件内部有一个`ApplicationModuleImpl` 类作为 `ModuleApplicationService` 的实现类。

代码如下：

```swift
extension Module.RegisterService {
    // 注册服务，注册服务时不会创建 Impl 对应的实例，实例创建发生在第一次使用service 时
    @objc static func applicationModule() {
        // 替换 ModuleApplicationService 的 Impl
        Module.register(service: ModuleApplicationService.self, used: ApplicationModuleImpl.self)
        // 使用自定义 router 替换 ModuleRouteService 的 Impl
        Module.register(service: ModuleRouteService.self, used: ApplicationRouter.self)
        // 应用的配置内容
        Module.register(service: ModuleConfigService.self, used: ModuleConfigServiceImpl.self)
    }
}

class ApplicationModuleImpl: NSObject, ModuleApplicationService {
    // 提高 implPriority 的值用于替换原有的impl
    static var implPriority: Int { 100 }
        
    var window: UIWindow?
    
    required override init() {
        super.init()
        // 项目初始化的相关代码，可以放在 applicationWillAwake() 函数中执行
    }
    
    // 在调用 Module.Awake 的类方法列表前调用该方法，确保调用 Module.Awake 的类方法时相关的服务能正确使用
    func applicationWillAwake() {
        let config = Module.service(of: ModuleConfigService.self)
        Module.tabService.tabBarControllerType = config.tabBarControllerType
    }
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?
    ) -> Bool {
        requestRedirectRoutes()
        setupAppearance()
        addNotification()
        reloadMainViewController()
        
        return true
    }
    
    func reloadMainViewController() {}
    
    private func addNotification() {
        let notificationImpl = Module.notificationService
        notificationImpl.addObserver(forName: .didLogoutSuccess) { [weak self] _ in
            self?.reloadMainViewController()
        }.disposed(by: self)
        
        notificationImpl.addObserver(forName: .didLoginSuccess) { [weak self] _ in
            self?.reloadMainViewController()
        }.disposed(by: self)
    }
    
    private func requestRedirectRoutes() { }
    
    private func setupAppearance() {}
}
```

查看完整的[ApplicationModuleImpl](./Modules/ApplicationModule/ApplicationModule/Classes/ApplicationModuleImpl.swift)

## 要求

`iOS 10+`

## 安装

NNModule-swift 支持对单个功能的单独引用

```ruby
# 全量安装
pod 'NNModule-swift'
# URLRouter 安装
pod 'NNModule-swift/URLRouter'
# EventTransfer 安装
pod 'NNModule-swift/EventTransfer'
# StickyNotification 安装
pod 'NNModule-swift/StickyNotification'
```

## Example

这里提供了一个[Example App](./Example_ModuleManager/)来方便更好地理解。

1. 下载 Example App
2. 运行 `pod install` 或者 `pod update`
3. 编译并运行 App

## 作者

NeroXie, xyh30902@163.com

## 许可证

NNBox 基于 MIT 许可证，查看 LICENSE 文件了解更多信息。
