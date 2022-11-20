//
//  EventBus.swift
//  NNModule-swift
//
//  Created by NeroXie on 2022/5/31.
//

import Foundation

public class EventBus {
    
    private var queue: DispatchQueue
    
    private var eventMap: [String: EventSet<Any>] = [:]
    
    public static let `default` = EventBus()
    
    public required init() {
        queue = DispatchQueue(label: "com.nn.default.eventbus", attributes: .concurrent)
    }
    
    public convenience init(queueName: String) {
        self.init()
        queue = DispatchQueue(label: queueName, attributes: .concurrent)
    }
    
    public func register<Event>(_ eventType: Event.Type, target: AnyObject) {
        guard target is Event else {
            assertionFailure("\(type(of: target)) must conforms to the event: \(eventType)")
            return
        }
        
        let eventName = "\(eventType)"
        write(in: queue) {
            let targetSet = self.eventMap[eventName] ?? EventSet<Any>()
            targetSet.addTarget(target)
            self.eventMap[eventName] = targetSet
        }
    }
    
    public func remove<Event>(_ eventType: Event.Type, target: AnyObject) {
        guard target is Event else { return }
        
        let eventName = "\(eventType)"
        write(in: queue) {
            guard let targetSet = self.eventMap[eventName] else { return }
            
            targetSet.removeTarget(target)
            if targetSet.count <= 0 { self.eventMap.removeValue(forKey: eventName) }
        }
    }
    
    public func remove<Event>(_ eventType: Event.Type) {
        let eventName = "\(eventType)"
        write(in: queue) { self.eventMap.removeValue(forKey: eventName) }
    }
    
    public func removeNilTargets<Event>(_ eventType: Event.Type) {
        let eventName = "\(eventType)"
        write(in: queue) {
            guard let targetSet = self.eventMap[eventName] else { return }
            
            targetSet.removeNilTargets()
            if targetSet.count <= 0 { self.eventMap.removeValue(forKey: eventName) }
        }
    }
    
    public func send<Event>(_ eventType: Event.Type, closure: (Event) -> Void) {
        let eventName = "\(eventType)"
        var targetSet: EventSet<Any>?
        read(in: queue) { targetSet = self.eventMap[eventName] }
        targetSet?.send { if let event = $0 as? Event { closure(event) } }
    }
}
