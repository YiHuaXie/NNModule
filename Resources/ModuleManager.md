# ModuleManager设计介绍

## 背景

进行组件化开发的过程中，随着项目的演进，我们慢慢地会发现，一些原本不需要依赖的业务模块都耦合到了一起，这其中必然是有很多原因的，可能是业务的发展方向发生变化，也可能是一开始自己设计的时候出现纰漏。

当我第一次接触组件化的时候，我也是非常纠结代码应该怎么放，放在什么地方，模块应该如何通信...... 根据自己的项目经历，我写了一个 ModuleMager 用于Swift项目的模块管理，主要用于业务模块之间的解耦（这里并不包含一些基础模块，如网络层），希望通过 ModuleManager 向大家提供一种思路，对遇到类似问题的同学能有所启发。

## 何为服务

ModuleManger 以注册服务的方式为核心进行组件间的解耦。服务的本质就是定义了一系列行为的一套接口，ModuleManager 将所有需要跨模块通信的功能全部定义为服务。在 ModuleManager 中所有提供的服务均基于 `ModuleBasicSerivce` ，它需要一个对应的实现者，在项目中我们称为 Impl。调用者是通过定义好的服务进行接口调用，而不是通过具体的类名即具体的 Impl 类调用接口。

`ModuleBasicService` 定义如下：

```swift
public protocol ModuleBasicService: AnyObject {
    // 构造方法
    init()
    // 创建 Impl 实例
    static var implInstance: Self { get }
}

public extension ModuleBasicService {
     // 获取 Impl 实例默认实现
    static var implInstance: ModuleBasicService { self.init() }
}
```

### 功能类服务

我们将需要进行跨模块通信的一些功能集抽象为一种功能类服务，所有的功能类服务均基于`ModuleFunctionalService`。功能类服务对应的 Impl 负责实现功能类服务中的所有接口，它与功能类服务为1对1关系，即使在项目中有多个类实现了同一个功能类服务（即有多个Impl），但是实际调用的 Impl 实例有且只有一个。每个功能类服务的 Impl 是分散各个模块中的，调用者只需要知道某个功能类服务能提供某个行为即可，对于具体的 Impl 的具体信息大可不必关心。

`ModuleFunctionalService`定义如下：

```swift
public protocol ModuleFunctionalService: ModuleBasicService {
    // Impl 优先级
    static var implPriority: Int { get }
}

public extension ModuleFunctionalService {
    
    static var implPriority: Int { 0 }
}
```

`implPriority` 用于指定 Impl 类的优先级，当某个功能类服务存在多个 Impl 类时，只会选择优先级最高的 Impl 类作为功能类服务的 Impl。

根据对功能类服务的说明，得到下面这个关系图：

![功能类服务类图](https://neroblog.oss-cn-hangzhou.aliyuncs.com/nn_module_func_service_uml.png)

示例代码如下：

```swift
// 注册路由服务
Module.register(service: ModuleRouteService.self, used: URLRouter.self)
// 注册登录服务
Module.register(service: LoginService.self, used: LoginManager.self)

// 通过路由服务注册路由
Module.routeService.registerRoute("xxxx") { url, navigator in
    print(url.parameters)
    navigator.push(A2ViewController())
    
    return true
}

// 通过路由服务调用路由
Module.routeService.openRoute("xxxx", parameters: ["model": xxxx])

// 通过登录服务获取是否登录
Module.service(of: LoginService.self).isLogin
```

### 注册类服务

对于某些功能类服务（比如路由服务）来说，它自身就需要由其他模块为它注册内容，因此衍生出一系列注册类服务。注册类服务的职责便是为功能类服务注册内容，在 Modulemanager 中所有的注册类服务均基于 `ModuleRegisteredService`，它同样需要有对应的 Impl 来实现所有的接口，但与功能类服务的不同的是，注册类服务与 Impl 为1对多关系，多个 Impl 共同完成某个功能类服务的注册内容。

`ModuleRegisteredService` 的定义如下：

```swift
public protocol ModuleRegisteredService: ModuleBasicService {
    // 是否保活实例，默认为 false
    static var keepaliveRegiteredImpl: Bool { get }
}

public extension ModuleRegisteredService {
    
    static var keepaliveRegiteredImpl: Bool { false }
}
```

`keepaliveRegiteredImpl` 用于保活实例，这么设计处于以下几个方面考虑：

1. 若没有其他对象持有会导致它被调用完后会被释放，如果这些 Impl 涉及到数据操作的话，很容易出现数据错误和丢失的情况
2. 基于第1点提到的情况，虽然 `ModuleBasicService` 的 `implInstance` 可以指定实例比如单例对象，但是我们不能对所有的 impl 类都声明一个单例属性，这显然是不必要的
3. 对于某些类来说，它可能是A功能的实现者，同时它又要为B功能提供注册，那么设置`keepaliveRegiteredImpl` 属性为 true 可以保证实例的唯一性以及防止数据分散在不同的实例上 

举个例子，ModuleManager 中有一个用于 TabBar 配置的服务 `ModuleTabService`，对，每个 tabBar Item 对应 ViewController 位于不同的业务模块中，为了解耦我们不能直接将这些 ViewController 所在的 module 直接引入，因此需要一个注册 tabBar Item 的 `RegisterTabItemService` 服务来帮助 `ModuleTabService` 对应的 Impl 获取到所有的 TabBarItem。

根据上面所述，可以得到下面这个类图：

![tab服务类图](https://neroblog.oss-cn-hangzhou.aliyuncs.com/nn_module_tab_service_uml.png)

示例代码如下：

```swift
// tabService 额外提供添加注册类服务的接口 RegisterTabItemService
// 调用 tabSerivce 添加 RegisterTabItemService 的 Impl
Module.tabService.addRegister(BModuleImpl.self)

// BModuleImpl 作为 RegisterTabItemService 的 Impl
class BModuleImpl: NSObject, RegisterTabItemService {
    
    func registerTabBarItems() -> [TabBarItemMeta] {
        let config = Module.service(of: ModuleConfigService.self)
        guard let index = config.tabBarItemIndex(for: "user") else { return [] }
        
        let bundle = resourceBundle(of: "BModule")
        let nav = UINavigationController(rootViewController: UserViewController())
        let image = UIImage(named: "tabbar_user_normal", in: bundle, compatibleWith: nil)
        let selectedImage = UIImage(named: "tabbar_user_normal", in: bundle, compatibleWith: nil)
        nav.tabBarItem = ESTabBarItem(NormalTabBarItemContentView(), title: "user", image: image, selectedImage: selectedImage)
        let meta = TabBarItemMeta(viewController: nav, tabIndex: index)
        return [meta]
    }
}
```

## 服务注册

通过前面的介绍相信你已经了解如何通过声明服务去进行组件解耦的了，现在的问题是我们在什么时机去注册这些服务。这里有两点是非常明确的：

1. 注册服务的时机一定是在获取服务对应的实例之前就必须完成的，因此我们需要寻找足够早的时机。
2. 注册服务的代码实现一定是分散在各个业务组件中，不可能全部放在一起。

在 OC 中我们可以通过 `load` 函数实现服务的注册，但是 Swift 不再支持 `load` 这样的函数，因此我们可能要自己实现一个类似的功能。

### 方案1.使用json配置+指定类+接口

该方案的大致思路：

1. 在主工程中用一个 json 文件去保存所有的业务模块
2. 定义出一套注册服务的接口，然后让每个业务模块的指定类去实现这套接口
3. 当 App 初始化的时读取这个 json 文件获取所有的业务模块，并调用模块中的指定类的接口完成服务的注册

大致实现如下：

在主工程中定义一个 **module_config.json** 文件，格式如下：

```json
{
    "modules": [
        "AModule",
        "BModule",
        "CModule"
    ] 
}
```

定义注册服务的接口 `RegisterServiceProtocol`，代码如下：

```swift
public protocol RegisterServiceProtocol {

    static func registerService()
}
```

我们规定每个业务模块需要创建一个以 **业务模块名+Impl** 为规则的类，用这个类来实现 `RegisterServiceProtocol` 中的接口，代码如下：

```swift
// AModule 中的 AModuleImpl 类
class AModuleImpl: RegisterServiceProtocol {

    // register service
    static func registerService() {
        Module.register(service: HomeService.self, used: HomeManager.self)
    }
    
    // ... other code
}
```

虽然上述方法是可行的，但是在实际应用的时候可能会有几个问题：

1. json 文件在没有脚本辅助的情况下容易忘记更改，导致服务不生效。
2. 业务模块的 **ModuleImpl** 类承担着业务模块中心管理的角色，当业务模块极其复杂时可能会导致 **ModuleImpl** 类比较复杂。虽然业务模块复杂绝大部分可能因为业务拆解有问题，但我依旧希望能通过代码的方式进行一次挽救来减少这个文件的代码量。
3. 集中式管理太多，主工程的 **module_config.json** 文件、各个业务模块下的 **ModuleImpl** 类都是集中式管理，一旦组件发生变动，会经常性的涉及到这些文件的修改。

针对上述的问题，我曾经尝试使用 Runtime 遍历所有类的方式去加载所有的类，并从中筛选出那些遵循协议的类调用相关注册接口，但是测试结果证明，`objc_getClassList` 函数执行的耗时比较久，此路不通。但是如果想要减少集中式管理，我们就不得不使用动态机制，一旦涉及到动态调用，我们只能去从 Runtime 中去找解决方案（虽然是 swift 项目，但也不得已为之）。

### 方案2. 调用指定类方法列表中的所有方法

从 Runtime 中我们可以知道，通过 `class_copyMethodList` 函数可以获取到类的所有方法，另外分类可以非常灵活的添加方法。如果我们能指定一个类，并在 App 启动时调用它的类方法列表中的所有方法，那么是不是就能实现类似于 `load` 函数的效果。

使用分类的话会存在一个问题，当分类中出现同名函数的时候，`class_copyMethodList`确实有两个函数地址，但是调用时只会调用编译顺序最后添加的方法，这是因为 `objc_msgSend`的机制，但是在实际情况中我们并不能保证不出现同名函数的可能性，所以使用`objc_msgSend` 的方式调用可能是行不通的。好在 Runtime 提供了 `method_invoke` 函数，它可以直接调用函数的指针而且性能比消息机制还快。

还有一点需要注意，`class_copyMethodList` 中保存的是 OC 函数，对于 Swift 项目来说，需要在函数声明中添加 `@objc` 标记。

理清楚思路，我们就可以实现如何方法列表中的所有方法，实现如下：

```swift
// 调用类的类方法列表
func loadAllMethods(from aClass: AnyClass) {
    guard let metaClass: AnyClass = object_getClass(aClass) else { return }
    
    var count: UInt32 = 0
    guard let methodList = class_copyMethodList(metaClass, &count) else { return }
    
    let handle = dlopen(nil, RTLD_LAZY)
    let methodInvoke = dlsym(handle, "method_invoke")
    
    for i in 0..<Int(count) {
        let method = methodList[i]
        unsafeBitCast(methodInvoke, to:(@convention(c)(Any, Method)->Void).self)(metaClass, method)
    }
    
    dlclose(handle)
    free(methodList)
}
```

基于这个方案，我们在业务模块中注册服务将会变得异常的简单，只需要添加分类，在分类中添加带有`@objc`标记的类方法即可。由于分类添加函数的灵活性，对于解决 **ModuleImpl** 类中代码臃肿也起到了比较大的帮助。

经过模拟测试，假设某个类有1000个分类，每个分类中都有一个类方法，通过 `method_invoke` 调用这个1000个不包含具体代码的类方法的耗时小于2毫秒，方案的函数耗时比对可以运行 [Example_RegisterationTime](../Example_RegisterationTime)

### Module.RegisterService

ModuleManager 中声明了 `Module.RegisterService` 用来提供注册功能类服务的时机。
在 `Module.RegisterService` 分类中添加类方法，使用`Module.register<Service>(service serviceType: Service.Type, used implClass: AnyClass)`即可完成功能类服务的注册。

ModuleManager 会在初始化时调用 `Module.RegisterService` 的所有类方法列表完成所有功能类服务的注册。在注册功能类服务的过程是不会初始化 Impl，Impl 的实例初始化会放在第一次使用服务的时候，这主要为了减少在 App 启动大量创建 Impl 的实例。

示例代码如下：

```swift
// 在 AModule 组件内添加 Module.RegisterService 分类，注册 HouseService
extension Module.RegisterService {
    
    @objc static func aModuleRegisterService() {
        Module.register(service: HouseService.self, used: HouseManager.self)
    }
}
```

需要注意两点：

1. 在 `Module.RegisterService` 分类的类方法中尽量不要初始化功能类服务的 Impl 实例或使用功能类服务，因为不确定使用到的功能类服务是否都已完成注册
2. 功能类服务的 Impl 类的初始化函数中使用其他功能类服务要避免形成环路

### Module.Awake

ModuleManager 中声明了 `Module.Awake` 为某些功能类服务提供添加注册类服务的时机。比如 ModuleManager 中默认提供了 routeService、tabService、launchTaskService，这些功能类服务都是需要各个业务模块为它们提供注册类服务。

在 `Module.AModule` 分类中添加类方法，调用功能类服务的相关接口完成注册类服务的注册。

示例代码如下：

```swift
// 在 BModule 组件内添加 Module.Awake 分类，添加路由与启动任务
extension Module.Awake {
    
    @objc static func bModuleAwake() {
        Module.launchTaskService.addRegister(ModuleLaunchTaskTest.self)
        Module.routeService.registerRoute("xxxx") { url, navigator in
            // do some thing
            
            return true
        }
    }
}
```

需要注意两点：

1. 在调用 `Module.Awake` 分类的类方法时，应用已经完成了所有功能类服务的注册，可以使用相关的功能类服务
2. 对于有注册类服务的功能类服务来说，在正常使用功能前需要所有注册类服务的 Impl 类完成注册

## ModuleManager提供的解耦方式

### 1. 面向协议的服务注册

通过面向协议的服务注册方案是整个 ModuleManager 的核心思路，它通过服务注册的方式来实现远程接口调用的。业务模块提供自己对外服务的协议声明到中间层（这个中间层指的是所有业务模块均需要依赖的某个公共模块），调用方可以通过查看中间层定义的接口来进行具体的调用。

如下图：

![ModuleSerivces中定义的服务](https://neroblog.oss-cn-hangzhou.aliyuncs.com/nn_module_services.jpg)

示例代码如下：

```swift
// 提前注册Login服务
Module.register(service: LoginService.self, used: LoginManager.self)

// 获取Login服务的Impl实例
let loginImpl = Module.service(of: LoginService.self)
// 获取是否登录
loginImpl.isLogin
```

### 2. 基于 URL 的路由方案

使用路由进行跳转是最常见的页面解耦方式，关于路由的具体的使用方式可以查看[NNModule-swift/URLRouter](./URLRouter.md)。

示例代码如下：

```swift
// 注册路由
Module.routeService.register("A2Page") { url, navigator in
    print(url.parameters)
    navigator.push(A2ViewController())
    
    return true
}

// 路由跳转
Module.routeService.open("A2Page", parameters: ["model": self])
```

### 3. 基于协议的远程接口调用

基于协议的远程接口调用设计初衷是为了替代使用 `performSelector` 进行远程接口调用，`performSelector` 函数除了自身语法比较有些隐晦以外，API 只支持1对1的调用（虽然可以通过封装做到1对多的效果），思前想后最终还是决定使用协议的方式进行远程接口调用。

NNModule-swift 提供了 EventSet 和 EventBus 类，均通过事先定义好的接口进行远程调用。EventSet 是一个多代理，EventBus可以理解为是一个面向协议的通知中心。关于 EventSet 和 EventBus 的具体的使用方式可以查看[NNModule-swift/EventTransfer](./EventTransfer.md)。

示例代码如下：

```swift
// 监听登录相关接口
EventBus.default.register(LoginEvent.self, target: self)

// 调用登录成功
EventBus.default.send(LoginEvent.self) { $0.didLoginSuccess() }
```

### 4. 基于 NotificationCenter 的通知方案

基于通知的模块间通讯方案，实现思路非常简单， 直接基于系统的 NSNotificationCenter 即可。优势是实现简单，非常适合处理一对多的通讯场景。劣势是仅适用于简单通讯场景。复杂数据传输，同步调用等方式都不太方便。模块化通讯方案中，更多的是把通知方案作为以上几种方案的补充。具体使用方式可以查看[NNModule-swift/StickyNotification](./StickyNotification.md)

## ModuleManager 的具体使用

关于 ModuleManager 的具体使用可查看[NNModule-swift](../README.md)。


