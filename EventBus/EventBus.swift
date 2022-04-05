//
//  EventBus.swift
//  NNModule-swift
//
//  Created by NeroXie on 2022/4/4.
//

import Foundation

public class EventBus {
    
    fileprivate let queue = DispatchQueue(
        label: "com.nn.default.EventBus",
        attributes: .concurrent
    )
    
    fileprivate var observersMap: [String: TargetSet<Any>] = [:]
    
    public static let `default` = EventBus()
    
    public required init() {}
    
    public func register<Event>(_ eventType: Event.Type, target: AnyObject) {
        guard target is Event else {
            assertionFailure("\(type(of: target)) must conforms to the event: \(eventType)")
            
            return
        }
        
        safeInsert(target: target, with: "\(eventType)")
    }
    
    public func remove<Event>(_ eventType: Event.Type, target: AnyObject) {
        guard target is Event else { return }
        
        safeRemove(target: target, with: "\(eventType)")
    }
    
    public func remove<Event>(_ eventType: Event.Type) {
        safeRemove(key: "\(eventType)")
    }
    
    public func notify<Event>(_ eventType: Event.Type, closure: (Event) -> Void ) {
        guard let targetSet = safeGetSet(key: "\(eventType)") as? TargetSet<Event> else { return }
        targetSet.send(closure)
    }
    
    func safeInsert(target: AnyObject, with key: String) {
        queue.async(flags: .barrier) { [weak self] in
            guard let `self` = self else { return }
            
            var set = self.observersMap[key] ?? TargetSet<Any>()
            set.addTarget(target)
            self.observersMap[key] = set
        }
    }
    
    func safeRemove(target: AnyObject, with key: String) {
        queue.async(flags: .barrier) { [weak self] in
            guard let `self` = self else { return }
            
            if var set = self.observersMap[key] {
                set.removeTarget(target)
                self.observersMap[key] = set.count > 0 ? set : nil
            }
        }
    }
    
    func safeRemove(key: String) {
        queue.async(flags: .barrier) { [weak self] in
            guard let `self` = self else { return }
            
            self.observersMap.removeValue(forKey: key)
        }
    }
    
    func safeGetSet(key: String) -> TargetSet<Any>? {
        var set: TargetSet<Any>?
        queue.sync { [weak self] in
            guard let `self` = self else { return }
            
            set = self.observersMap[key]
        }
        
        return set
    }
}
