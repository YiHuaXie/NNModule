//
//  EventSet.swift
//  NNModule-swift
//
//  Created by NeroXie on 2022/4/4.
//

import Foundation

public class EventSet<Event> {
    
    public private(set) var queue: DispatchQueue? = nil
    
    private var targetSet = Set<WeakTarget>()
    
    public required init() {}
    
    public convenience init(isThreadSafe: Bool = false) {
        self.init()
        if isThreadSafe { queue = DispatchQueue(label: "com.nn.default.eventset", attributes: .concurrent) }
    }
    
    public convenience init(queueName: String) {
        self.init()
        queue = DispatchQueue(label: queueName, attributes: .concurrent)
    }
    
    public func addTarget(_ target: AnyObject) {
        guard target is Event else {
            assertionFailure("\(type(of: target)) must conforms to the event: \(Event.self)")
            return
        }
        
        let member = WeakTarget(target)
        write(in: queue) {
            if self.targetSet.contains(member)  { self.targetSet.remove(member) }
            self.targetSet.insert(member)
        }
    }
    
    public func removeTarget(_ target: AnyObject) {
        guard target is Event else { return }
        
        write(in: queue) { self.targetSet.remove(WeakTarget(target)) }
    }
    
    public func removeNilTargets() {
        write(in: queue) { self.targetSet = self.targetSet.filter { $0.target != nil } }
    }
    
    public func removeAll() {
        write(in: queue) { self.targetSet = Set<WeakTarget>() }
    }
    
    public func send(_ closure: (Event) -> Void ) {
        var targetSet:Set<WeakTarget>?
        read(in: queue) { targetSet = self.targetSet }
        targetSet?.forEach { if let target = $0.target as? Event { closure(target) } }
    }
    
    public var count: Int {
        var count: Int = 0
        read(in: queue) { count = self.targetSet.count }
        return count
    }
}

func read(in queue: DispatchQueue?, using block: () -> Void) {
    queue == nil ? block() : queue?.sync { block() }
}

func write(in queue: DispatchQueue?, using block: @escaping () -> Void) {
    queue == nil ? block() : queue?.async(flags: .barrier) { block() }
}



