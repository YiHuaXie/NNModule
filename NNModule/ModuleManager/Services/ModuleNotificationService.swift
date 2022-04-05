//
//  ModuleNotificationSerice.swift
//  ModuleManager
//
//  Created by NeroXie on 2020/12/30.
//

import Foundation

private var observerKey: Void?

public final class NotificationObserver {
    
    internal var next: NotificationObserver? = nil
    
    let observer: NSObjectProtocol
    
    public init(observer: NSObjectProtocol) {
        self.observer = observer
    }
    
    public func disposed(by pool: AnyObject) {
        if let observer = objc_getAssociatedObject(pool, &observerKey) as? NotificationObserver {
            next = observer
        }
        
        objc_setAssociatedObject(pool, &observerKey, self, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    deinit { NotificationCenter.default.removeObserver(observer) }
}

/// Notification Service
public protocol ModuleNotificationService: ModuleFunctionalService {
    
    /// Adds an entry to the notification center to receive notifications that passed to the provided block.
    /// - Parameters:
    ///   - name: The name of the notification to register for delivery to the observer block.
    ///   - isSticky: Determine whether it is a sticking event. 
    ///   - object: The object that sends notifications to the observer block.
    ///   - queue: The operation queue where the block runs.
    ///   - block: The block that executes when receiving a notification.
    /// - Returns: NotificationObserver
    func observe(
        name: String,
        isSticky: Bool,
        object: Any?,
        queue: OperationQueue?,
        using block: @escaping (Notification) -> Void
    ) -> NotificationObserver
    
    /// Creates a notification with a given name, sender, and information and posts it to the notification center.
    /// - Parameters:
    ///   - name: The name of the notification.
    ///   - object: The object posting the notification.
    ///   - userInfo: A user info dictionary with optional information about the notification.
    ///   - isSticky: It is a sticking event.
    func post(
        name: String,
        object: Any?,
        userInfo: [AnyHashable: Any]?,
        isSticky: Bool
    )
}

extension ModuleNotificationService {
    
    public func observe(
        name: String,
        isSticky: Bool = false,
        object: Any? = nil,
        queue: OperationQueue? = nil,
        using block: @escaping (Notification) -> Void
    ) -> NotificationObserver {
        observe(name: name, isSticky: isSticky, object: object, queue: queue, using: block)
    }
    
    public func post(
        name: String,
        object: Any? = nil,
        userInfo: [AnyHashable: Any]? = nil,
        isSticky: Bool = false
    ) {
        post(name: name, object: object, userInfo: userInfo, isSticky: isSticky)
    }
}


