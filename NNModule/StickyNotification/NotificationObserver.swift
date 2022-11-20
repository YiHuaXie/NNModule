//
//  NotificationObserver.swift
//  NNModule-swift
//
//  Created by NeroXie on 2022/11/17.
//

import Foundation

private var observerKey: Void?

public final class NotificationObserver {

    private var next: NotificationObserver? = nil

    private weak var center: NotificationCenter? = nil

    public let observer: NSObjectProtocol

    public init(observer: NSObjectProtocol, center: NotificationCenter) {
        self.observer = observer
        self.center = center
    }

    public func disposed(by pool: AnyObject) {
        if let observer = objc_getAssociatedObject(pool, &observerKey) as? NotificationObserver {
            next = observer
        }

        objc_setAssociatedObject(pool, &observerKey, self, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    deinit { center?.removeObserver(observer) }
}
