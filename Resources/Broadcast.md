# Broadcast

## 简介

基于协议进行远程接口的调用，包含 Multicast 和 Broadcast。

+ Multicast：1对多的接口调用，适用于多代理场景。
+ Broadcast：面向协议的通知中心。

Multicast 和 Broadcast 是类型安全的、线程安全的和内存安全的。另外对于Target是弱引用关系，因此无需手动remove。

## 使用

### Multicast

定义事件 

```swift
protocol AEvent {
    func aMethod1()
    func aMethod2()
}

class AModel: AEvent {
    init() {}
    func aMethod1() {
        debugPrint("\(self) \(#function)")
    }
    func aMethod2() {
        debugPrint("\(self) \(#function)")
    }
}
```

调用

```swift
var aModel = AModel()
var bModel = BModel()

let aMulticast = Multicast<AEvent>()
// 注册事件监听
aMulticast.registerTarget(aModel)
aMulticast.registerTarget(bModel)
// 发送事件
aMulticast.send { $0.aMethod1() }
aMulticast.send { $0.aMethod2() }
// 删除事件监听者方法1
aModel = AModel()
// 删除事件监听者方法2
aMulticast.removeTarget(aModel)
// 删除所有空target
aMulticast.removeNilTargets()
```

### Broadcast

定义

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
    
    func aMethod1() {
        debugPrint("\(self) \(#function)")
    }
    
    func aMethod2() {
        debugPrint("\(self) \(#function)")
    }
    
    func bMethod1() {
        debugPrint("\(self) \(#function)")
    }
    
    func bMethod2() {
        debugPrint("\(self) \(#function)")
    }
}

class BModel: AEvent {
    init() {}
    
    func aMethod1() {
        debugPrint("\(self) \(#function)")
    }
    
    func aMethod2() {
        debugPrint("\(self) \(#function)")
    }
}
```

调用

```swift
var aModel = AModel()
var bModel = BModel()
// 注册事件监听         
Broadcast.default.register(AEvent.self, target: aModel)
Broadcast.default.register(AEvent.self, target: bModel)
Broadcast.default.register(BEvent.self, target: aModel)
// 发送事件      
Broadcast.default.send(AEvent.self) { $0.aMethod1() }
Broadcast.default.send(AEvent.self) { $0.aMethod2() }
Broadcast.default.send(BEvent.self) { $0.bMethod1() }
Broadcast.default.send(BEvent.self) { $0.bMethod2() }

// 删除事件监听者方法1
aModel = nil
// 删除事件监听者方法2
Broadcast.default.remove(AEvent.self, target: aModel)
// 删除某个事件的所有监听者
Broadcast.default.remove(AEvent.self)
// 删除某个事件下的所有空target
Broadcast.default.removeNilTargets(AEvent.self)
```

## 要求

`iOS 10+`

## 安装

```ruby
pod 'NNModule-swift/Broadcast'
```

## Example

这里提供了一个[Example App](../Example_Broadcast/)。

1. 下载Example App
2. 运行`pod install`或者`pod update`
3. 编译并运行App
4. 执行Example_BroadcastTests.swift中的测试用例

## 其他功能

点击[这里](../README.md)可查看 NNModule-swift 的其他功能。