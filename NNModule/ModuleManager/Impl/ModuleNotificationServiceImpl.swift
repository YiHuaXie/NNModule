//
//  ModuleNotificationServiceImpl.swift
//  ModuleManager
//
//  Created by NeroXie on 2020/12/30.
//

import Foundation

class ModuleNotificationServiceImpl: NSObject, ModuleNotificationService {
    
    required override init() { super.init() }
    
    func addObserver(
        forName name: NSNotification.Name?,
        isSticky: Bool,
        object: Any?,
        queue: OperationQueue?,
        using block: @escaping (Notification) -> Void
    ) -> NotificationObserver {
        NotificationCenter.default.addObserver(
            forName: name,
            isSticky: isSticky,
            object: object,
            queue: queue,
            using: block
        )
    }
    
    func post(name: Notification.Name, isSticky: Bool, object: Any?, userInfo: [AnyHashable : Any]?) {
        NotificationCenter.default.post(name: name, isSticky: isSticky, object: object, userInfo: userInfo)
    }
    
    func removeStickyNotification(for name: Notification.Name) {
        NotificationCenter.default.removeStickyNotification(for: name)
    }
}
