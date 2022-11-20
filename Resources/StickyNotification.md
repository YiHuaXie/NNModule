# StickyNotification

## 简介

NotificationCenter 增加带 sticky notification 的功能，在使用支持 sticky notification 的 API 注册通知时，会先发送一次最近发送过的 notification，并根据与发送的 notification 的匹配决定是否调用 block。

成功接收 sticky notification 的条件：

+ isSticky 为 true
+ 注册通知使用的 object 为 nil 或者与 sticky notication 中的 object 匹配
+ NotificationCenter 在添加通知前发送过同名且 isSticky 为 true 的通知

## 使用

注册通知

```swift
// 创建自动释放参照对象
let objc1 = NSObject()
let name = Notification.Name("test")
// isSticky 为 true，若之前发送过对应的 notificaion，block 会先执行一次
NotificationCenter.default.addObserver(forName: name, isSticky: true, object: nil, queue: nil) {
    print("objc1 receive: \($0)")
}
// objc1 被释放时，会自动释放该通知
.disposed(by: objc1)
```

发送通知

```swift
let name = Notification.Name("test")
// 发送通知 isSticky 为 true，更新 test 通知的最新值
NotificationCenter.default.post(name: name, isSticky: true, userInfo: ["id": "789"])
```

## 要求

`iOS 10+`

## 安装

```ruby
pod 'NNModule-swift/StickyNotification'
```

## Example

这里提供了一个[Example App](../Example_StickyNotification/)。

1. 下载 Example App
2. 运行 `pod install `或者 `pod update`
3. 编译并运行 App
4. 执行 Example_StickyNotificationTests.swift 中的测试用例

## 其他功能

点击[这里](../README.md)可查看 NNModule-swift 的其他功能。