//
//  ModuleNotificationServiceImpl.swift
//  ModuleManager
//
//  Created by NeroXie on 2020/12/30.
//

import Foundation

@objc extension NotificationCenter {
    
    /// Adds an entry to the notification center to receive notifications that passed to the provided block.
    /// - Parameters:
    ///   - name: The name of the notification to register for delivery to the observer block.
    ///   - isSticky: The tag of receiving sticky notification. When true, the block will be executed first if there is a sticky notification matches.
    ///   - object: The object that sends notifications to the observer block.
    ///   - queue: The operation queue where the block runs.
    ///   - block: The block that executes when receiving a notification.
    /// - Returns: An opaque object to act as the observer.
    public func addObserver(
        forName name: NSNotification.Name?,
        isSticky: Bool = false,
        object: Any? = nil,
        queue: OperationQueue? = nil,
        using block: @escaping (Notification) -> Void
    ) -> NotificationObserver {
        let observer = addObserver(forName: name, object: object, queue: queue, using: block)
        // has the latest sticky value
        guard isSticky, let nameValue = name?.rawValue, let notification = stickyMap[nameValue] else {
            return NotificationObserver(observer: observer, center: self)
        }
        
        // object matches sticky notification
        guard self.notification(notification, matching: object) else {
            return NotificationObserver(observer: observer, center: self)
        }
        
        if let queue = queue, queue != OperationQueue.current {
            queue.addOperation { block(notification) }
            queue.waitUntilAllOperationsAreFinished()
        } else {
            block(notification)
        }
        
        return NotificationObserver(observer: observer, center: self)
    }
    
    /// Creates a notification with a given name, sitcky tag, sender, and information and posts it to the notification center.
    /// - Parameters:
    ///   - name: The name of the notification.
    ///   - isSticky: The tag of saving sticky notification. When true, it will save the notification as the latest sticky notification.
    ///   - object: The object posting the notification.
    ///   - userInfo: A user info dictionary with optional information about the notification.
    public func post(name: Notification.Name, isSticky: Bool = false, object: Any? = nil, userInfo: [AnyHashable : Any]? = nil) {
        let notification = Notification(name: name, object: object, userInfo: userInfo)
        post(notification)
        if isSticky { stickyMap[name.rawValue] = notification }
    }
    
    /// Removes the sticky notification.
    /// - Parameter name: The name of the notification.
    public func removeStickyNotification(for name: Notification.Name) {
        stickyMap[name.rawValue] = nil
    }
    
    private func notification(_ notification: Notification, matching sender: Any?) -> Bool {
        guard let sender = sender else { return true }
        guard let object = notification.object, type(of: sender) == type(of: object) else { return false }
                
        return (sender as AnyObject) === (object as AnyObject) ||
        sender is String && (object as? String) == (sender as? String) ||
        sender is Bool && (sender as? Bool) == (object as? Bool) ||
        sender is Int64 && (object as? Int64) == (sender as? Int64) ||
        sender is Double && (object as? Double) == (sender as? Double)
    }

    private var stickyMapLock: NSLock {
        if let lock = objc_getAssociatedObject(self, &stickyMapLockKey) as? NSLock { return lock }
        
        let lock = NSLock()
        objc_setAssociatedObject(self, &stickyMapLockKey, lock, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        return lock
    }
    
    private var stickyMap: [String: Notification] {
        set {
            stickyMapLock.lock()
            defer { stickyMapLock.unlock() }
            
            objc_setAssociatedObject(self, &stickyMapKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        get {
            stickyMapLock.lock()
            defer { stickyMapLock.unlock() }
            
            if let map = objc_getAssociatedObject(self, &stickyMapKey) as? [String: Notification] { return map }
            
            let map = [String: Notification]()
            objc_setAssociatedObject(self, &stickyMapKey, map, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return map
        }
    }
}

private var stickyMapKey: Void?

private var stickyMapLockKey: Void?
