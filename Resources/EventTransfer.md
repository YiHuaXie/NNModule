# EventTransfer

## 简介

基于协议进行远程接口的调用，包含 EventSet 和 EventBus。

+ EventSet：1对多的接口调用，适用于多代理场景。
+ EventBus：面向协议的事件总线。

EvnetSet 和 EventBus 是类型安全的，对于Target是弱引用关系，因此无需手动remove。关于线程安全，EventSet 根据使用场景的不同支持非线程安全（比如UI相关的多代理）和线程安全的多代理，EventBus 则是线程安全的。

## 使用

### EventSet

定义接口

```swift
protocol AEvent {

    func aMethod1()

    func aMethod2()
}
```

实现接口

```swift
class AModel: AEvent {
    
    init() {}
    
    func aMethod1() { debugPrint("\(self) \(#function)") }
    
    func aMethod2() { debugPrint("\(self) \(#function)") }
}
```

调用

```swift
var aModel = AModel()
var bModel = BModel()

// 创建eventSet
let eventSet = EventSet<AEvent>()

// 注册事件监听
eventSet.addTarget(aModel)
eventSet.addTarget(bModel)

// 发送事件
aEventSet.send { $0.aMethod1() }
aEventSet.send { $0.aMethod2() }

// 删除事件监听者方法1
aModel = AModel()
// 删除事件监听者方法2
aEventSet.removeTarget(aModel)
// 删除所有空target
aEventSet.removeNilTargets()
```

### EventBus

定义接口

```swift
protocol AEvent {
    
    func aMethod1()
    
    func aMethod2()
}

protocol BEvent {
    
    func bMethod1()
    
    func bMethod2()
}

class AModel: AEvent, BEvent {
    
    init() {}
    
    deinit { debugPrint("\(self) \(#function)") }
    
    func aMethod1() { debugPrint("\(self) \(#function)") }
    
    func aMethod2() { debugPrint("\(self) \(#function)") }
    
    func bMethod1() { debugPrint("\(self) \(#function)") }

    func bMethod2() { debugPrint("\(self) \(#function)") }
}

class BModel: AEvent {
    
    init() {}
    
    deinit { debugPrint("\(self) \(#function)") }
    
    func aMethod1() { debugPrint("\(self) \(#function)") }
    
    func aMethod2() { debugPrint("\(self) \(#function)") }
}
```

调用

```swift
var aModel = AModel()
var bModel = BModel()

// 创建eventBus
let eventBus = EventBus.default
// 注册事件监听         
eventBus.register(AEvent.self, target: aModel)
eventBus.register(AEvent.self, target: bModel)
eventBus.register(BEvent.self, target: aModel)
// 发送事件      
eventBus.send(AEvent.self) { $0.aMethod1() }
eventBus.send(AEvent.self) { $0.aMethod2() }
eventBus.send(BEvent.self) { $0.bMethod1() }
eventBus.send(BEvent.self) { $0.bMethod2() }

// 删除事件监听者方法1
aModel = nil
// 删除事件监听者方法2
eventBus.remove(AEvent.self, target: aModel)
// 删除某类事件的所有监听者
eventBus.remove(AEvent.self)
// 删除某类事件下的所有空target
eventBus.removeNilTargets(AEvent.self)
```

## 要求

`iOS 10+`

## 安装

```ruby
pod 'NNModule-swift/EventTransfer'
```

## Example

这里提供了一个[Example App](../Example_EventTransfer/)。

1. 下载 Example App
2. 运行 `pod install `或者 `pod update`
3. 编译并运行 App
4. 执行 Example_EventTransferTests.swift 中的测试用例

## 其他功能

点击[这里](../README.md)可查看 NNModule-swift 的其他功能。