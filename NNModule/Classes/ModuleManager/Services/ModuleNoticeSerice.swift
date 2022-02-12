//
//  ModuleNoticeSerice.swift
//  ModuleManager
//
//  Created by NeroXie on 2020/12/30.
//

import Foundation

private var observerKey: Void?

public final class NoticeObserver {
    
    internal var next: NoticeObserver? = nil
    
    let observer: NSObjectProtocol
    
    public init(observer: NSObjectProtocol) {
        self.observer = observer
    }
    
    public func disposed(by pool: AnyObject) {
        if let observer = objc_getAssociatedObject(pool, &observerKey) as? NoticeObserver {
            next = observer
        }
        
        objc_setAssociatedObject(pool, &observerKey, self, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    deinit { NotificationCenter.default.removeObserver(observer) }
}

/// <#Description#>
public protocol ModuleNoticeService: ModuleFunctionalService {
    
    var stickyMap: [String: Notification] { set get }
    
    func observe(
        name: NSNotification.Name,
        isSticky: Bool,
        object: Any?,
        queue: OperationQueue?,
        using block: @escaping (Notification) -> Void
    ) -> NoticeObserver
    
    func post(
        name: Notification.Name,
        object: Any?,
        userInfo: [AnyHashable: Any]?,
        isSticky: Bool
    )
}

public extension ModuleNoticeService {
    
    func observe(
        name: NSNotification.Name,
        isSticky: Bool = false,
        object: Any? = nil,
        queue: OperationQueue? = nil,
        using block: @escaping (Notification) -> Void
    ) -> NoticeObserver {
        let observer = NotificationCenter.default.addObserver(forName: name, object: object, queue: queue) { block($0) }
        
        if isSticky, let notification = stickyMap[name.rawValue] { block(notification) }
        
        return NoticeObserver(observer: observer)
    }
    
    func post(
        name: Notification.Name,
        object: Any? = nil,
        userInfo: [AnyHashable: Any]? = nil,
        isSticky: Bool = false
    ) {
        let notification = Notification(name: name, object: object, userInfo: userInfo)
        NotificationCenter.default.post(notification)
        if isSticky { stickyMap[name.rawValue] = notification }
    }
}

