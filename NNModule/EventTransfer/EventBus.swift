//
//  EventBus.swift
//  NNModule-swift
//
//  Created by NeroXie on 2022/5/31.
//

import Foundation

public class EventBus {
    
    private var queue: DispatchQueue
    
    private var eventMap: [String: TargetSet<Any>]
    
    public static let `default` = EventBus()
    
    public required init(name: String) {
        eventMap = [:]
        queue = DispatchQueue(label: name, attributes: .concurrent)
    }
    
    public required convenience init() {
        self.init(name: "com.nn.default.EventBus")
    }
    
    public func register<Event>(_ eventType: Event.Type, target: AnyObject) {
        guard target is Event else {
            assertionFailure("\(type(of: target)) must conforms to the event: \(eventType)")
            return
        }
        
        let eventName = "\(eventType)"
        queue.async(flags: .barrier) { [weak self] in
            guard let `self` = self else { return }
            
            var targetSet = self.eventMap[eventName] ?? TargetSet<Any>()
            targetSet.addTarget(target)
            self.eventMap[eventName] = targetSet
        }
    }
    
    public func remove<Event>(_ eventType: Event.Type, target: AnyObject) {
        guard target is Event else { return }
        
        let eventName = "\(eventType)"
        queue.async(flags: .barrier) { [weak self] in
            guard let `self` = self, var targetSet = self.eventMap[eventName] else { return }
            
            targetSet.removeTarget(target)
            self.eventMap[eventName] = targetSet.count > 0 ? targetSet : nil
        }
    }
    
    public func remove<Event>(_ eventType: Event.Type) {
        let eventName = "\(eventType)"
        queue.async(flags: .barrier) { [weak self] in
            self?.eventMap.removeValue(forKey: eventName)
        }
    }
    
    public func removeNilTargets<Event>(_ eventType: Event.Type) {
        let eventName = "\(eventType)"
        queue.async(flags: .barrier) { [weak self] in
            guard let `self` = self, var targetSet = self.eventMap[eventName] else { return }
            
            targetSet.removeNilTargets()
            self.eventMap[eventName] = targetSet.count > 0 ? targetSet : nil
        }
    }
    
    public func send<Event>(_ eventType: Event.Type, closure: (Event) -> Void) {
        let eventName = "\(eventType)"
        var targetSet: TargetSet<Any>? = nil
        queue.sync { [weak self] in targetSet = self?.eventMap[eventName] }
        targetSet?.send { if let event = $0 as? Event { closure(event) } }
    }
}
