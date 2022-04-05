//
//  ModuleNotificationServiceImpl.swift
//  ModuleManager
//
//  Created by NeroXie on 2020/12/30.
//

import Foundation

class ModuleNotificationServiceImpl: ModuleNotificationService {
    
    var stickyMap: [String : Notification] = [:]
    
    required init() {}
    
    func observe(
        name: String,
        isSticky: Bool,
        object: Any?,
        queue: OperationQueue?,
        using block: @escaping (Notification) -> Void
    ) -> NotificationObserver {
        let notificationName: NSNotification.Name = .init(rawValue: name)
        let observer = NotificationCenter.default.addObserver(forName: notificationName, object: object, queue: queue) {
            block($0)
        }
        
        if isSticky, let notification = stickyMap[notificationName.rawValue] {
            (queue ?? OperationQueue.current)?.addOperation { block(notification) }
        }
        
        return NotificationObserver(observer: observer)
    }
    
    func post(
        name: String,
        object: Any?,
        userInfo: [AnyHashable : Any]?,
        isSticky: Bool
    ) {
        let notificationName: NSNotification.Name = .init(rawValue: name)
        let notification = Notification(name: notificationName, object: object, userInfo: userInfo)
        NotificationCenter.default.post(notification)
        
        if isSticky { stickyMap[notificationName.rawValue] = notification }
    }
}
