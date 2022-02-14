# NNModule-swift

[![CI Status](https://img.shields.io/travis/NeroXie/NNModule.svg?style=flat)](https://travis-ci.org/NeroXie/NNModule)
[![Version](https://img.shields.io/cocoapods/v/NNModule-swift.svg?style=flat)](https://cocoapods.org/pods/NNModule-swift)
[![License](https://img.shields.io/cocoapods/l/NNModule-swift.svg?style=flat)](https://cocoapods.org/pods/NNModule-swift)
[![Platform](https://img.shields.io/cocoapods/p/NNModule-swift.svg?style=flat)](https://cocoapods.org/pods/NNModule-swift)

## 简介

NNModule-swift 用于Swift项目的模块管理，主要用于业务模块之间的解耦（以协议的方式进行解耦）， 希望通过 NNModule 向大家提供一种思路，对遇到类似问题的同学能有所启发。

NNModule-swift 提供的功能如下：

+ 组件化管理器：[ModuleManager](./Resources/ModuleManager.md)
+ 路由：[URLRouter](./Resources/URLRouter.md)

## 使用

在使用 NNModule-swift 之前建议阅读[ModuleManager设计介绍](./Resources/ModuleManager.md)来理解服务解耦以及如何注册服务。另外提供了一个[Example App](../Example_ModuleManager/)来方便更好地理解。

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

### 使用路由

`ModuleRouteService`提供了路由功能，具体定义可以查看[ModuleRouteService](./NNModule/Classes/ModuleManager/Services/ModuleRouteService.swift)。
`ModuleRouteService`的Impl类是内部的 URLRouter，路由完整的使用方式可以查看[URLRouter](./Resources/URLRouter.md)。

#### 注册路由

在你需要的业务组件创建`Module.Awake`（该类用于注册注册类服务和功能类服务的初始化操作）分类并添加类方法，在类方法中完成路由的注册。这里要注意添加的类方法必须是带`@objc`标记的，至于方法名字可以随意写，甚至你不怕项目警告多的话可以使用同一个函数名比如 awake（即使存在同名函数的类方法在调用过程中也不会被覆盖）， 具体原因可以阅读[方案2：调用指定类方法列表中的所有方法](./Resources/ModuleManager.md)。

```swift
extension Module.Awake {
    
    @objc static func aModuleAwake() {
        Module.routeService.registerRoute("A2Page") { url, navigator in
            print(url.parameters)
            navigator.push(A2ViewController())
            
            return true
        }
        
        Module.routeService.registerRoute("A3Page") { url, navigtor in
            let vc = A3ViewController()
            navigtor.present(vc, wrap: UINavigationController.self)
            return true
        }
    }
}
```

#### 调用路由

```swift
Module.routeService.openRoute("A2Page", parameters: ["model": self])
```

### 使用TabBar

`ModuleTabService`用于获取项目中TabBar相关的功能，具体定义可以查看[ModuleTabService](./NNModule/Classes/ModuleManager/Services/ModuleTabService.swift)。

#### 指定TabBarController的类型

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

#### 注册TabBarItem

`RegisterTabItemService`提供为`ModuleTabService`注册tabBarItem的功能，具体定义可以查看[RegisterTabItemService](./NNModule/Classes/ModuleManager/Services/ModuleTabService.swift)。

注册 tabBar item 示例代码如下：

```swift
extension Module.Awake {
    
    @objc static func aModuleAwake() {
        Module.tabService.addRegister(AModuleImpl.self)
    }
}

class AModuleImpl: NSObject, RegisterTabItemService {

    override required init() {
        super.init()
    }
    
    func setupTabBarController(_ tabBarController: UITabBarController) {}
    
    func registerTabBarItems() -> [TabBarItemMeta] {
        let bundle = resourceBundle(of: "AModule")
        
        let vc1 = A1ViewController()
        vc1.modalPresentationStyle = .fullScreen
        let nav1 = UINavigationController(rootViewController: vc1)
        let image1 = UIImage(named: "tabbar_houses_normal", in: bundle, compatibleWith: nil)
        let selectedImage1 = UIImage(named: "tabbar_houses_normal", in: bundle, compatibleWith: nil)
        nav1.tabBarItem = ESTabBarItem(NormalTabBarItemContentView(), title: "home", image: image1, selectedImage: selectedImage1)
        let meta1 = TabBarItemMeta(viewController: nav1, tabIndex: 0)
        
        return [meta1]
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        print("\(type(of: self))：\(#function)")
        
        return true
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print("\(type(of: self))：\(#function)")
    }
}
```

### 其他功能类服务

除了上面提到的基础服务外还有`ModuleNoticeService`（通知）和`ModuleLaunchTaskService`(启动任务)，用法和上面类似这里就不一一介绍了。

其他可以查看

+ [ModuleNoticeService](./NNModule/Classes/ModuleManager/Services/ModuleNoticeService.swift)
+ [ModuleLaunchTaskService](./NNModule/Classes/ModuleManager/Services/ModuleLaunchTaskService.swift)


### 创建自定义的服务

项目中除了上面提到的基础服务外，还有很多关于业务的服务，这些是要我们自己创建并注册的。 以登录为例演示如何创建自定义的服务，这里的服务指的是功能类服务。

**定义LoginService用于提供登录相关的功能**

```swift
// Login service
public protocol LoginService: ModuleFunctionalService {
    
    /// the main viewController of LoginModule
    var loginMain: UIViewController { get }
    
    var isLogin: Bool { get }
    
    func updateLoginStatus(with login: Bool)
}

/// The notification of LoginModule
public enum LoginNotice: String {
    
    case didLoginSuccess
    
    case didLogoutSuccess
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
    
    static var implInstance: LoginManager { shared }
    
    var isLogin: Bool = false
    
    required init() {}
    
    var loginMain: UIViewController { LoginViewController() }
    
    func updateLoginStatus(with login: Bool) {
        isLogin = login
        let notice: LoginNotice = login ? .didLoginSuccess : .didLogoutSuccess
        Module.noticeService.post(name: Notification.Name(notice.rawValue))
    }
}
```

### 替换已有服务的Impl

由于`ModuleApplicationService`的默认Impl内没有任何逻辑，而在项目中该服务的Impl是一定需要替换，所以我们就以`ModuleApplicationService`作为例子来演示如何替换已有服务的Impl。

我们可以创建一个 ApplicationModule 的组件，该组件内部有一个`ApplicationModuleImpl`类作为`ModuleApplicationService`的实现者。

其实现如下：
```swift
extension Module.RegisterService {
    
    @objc static func applicationModule() {
        Module.register(service: ModuleApplicationService.self, used: ApplicationModuleImpl.self)
    }
}

extension Module.Awake {
    
    @objc static func applicationModule() {
        if let cls = NSClassFromString("TabBarController.TabBarController"),
           let tabBarType = cls as? UITabBarController.Type {
            Module.tabService.tabBarControllerType = tabBarType
        }
        
        Module.routeService.update(defaultScheme: "app")
    }
}

class ApplicationModuleImpl: NSObject, ModuleApplicationService {
    
    // 提高implPriority的值用于替换原有的impl
    static var implPriority: Int { 100 }
    
    required override init() {
        super.init()
        
        // 监听登录
    }
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?
    ) -> Bool {
        setupAppearance()
        reloadMainViewController()
       
        return true
    }
        
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("\(type(of: self)): \(#function)")
    }
    
    func application(
        _ app: UIApplication,
        open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        if let scheme = url.scheme?.lowercased(), scheme == Module.routeService.defaultScheme  {
            var newOptions = [String: Any]()
            options.forEach { newOptions[$0.rawValue] = $1 }
            
            return Module.routeService.openRoute(url.absoluteString, parameters: newOptions)
        }
        
        return false
    }
    
    func reloadMainViewController() {
        let loginImpl = Module.service(of: LoginService.self)
        let viewController: UIViewController = loginImpl.isLogin ? Module.tabService.tabBarController : loginImpl.loginMain
        
        if let delegate = UIApplication.shared.delegate, let window = delegate.window as? UIWindow {
            window.rootViewController = viewController
        }
    }
}
```

## 要求

`iOS 10+`

## 安装

NNModule-swift 支持对单个功能的单独引用

```ruby
# 全量安装
pod 'NNModule-swift'
# URLRouter安装
pod 'NNModule-swift/URLRouter'
```

## Example

这里提供了一个[Example App](../Example_ModuleManager/)来方便更好地理解。

1. 编译并安装Example App
2. 运行`pod install`或者`pod update`

## 作者

NeroXie, xyh30902@163.com

## 许可证

NNBox 基于 MIT 许可证，查看 LICENSE 文件了解更多信息。
