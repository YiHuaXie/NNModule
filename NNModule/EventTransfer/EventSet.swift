//
//  EventSet.swift
//  NNModule-swift
//
//  Created by NeroXie on 2022/4/4.
//

import Foundation

public class EventSet<Event> {
    
    private var queue: DispatchQueue
    
    private var targetSet: TargetSet<Event>
    
    public required init(name: String) {
        targetSet = TargetSet<Event>()
        queue = DispatchQueue(label: name, attributes: .concurrent)
    }
    
    public required convenience init() {
        self.init(name: "com.nn.default.EventSet")
    }
    
    public func registerTarget(_ target: AnyObject) {
        guard target is Event else {
            assertionFailure("\(type(of: target)) must conforms to the event: \(Event.self)")
            return
        }
        
        queue.async(flags: .barrier) { [weak self] in
            self?.targetSet.addTarget(target)
        }
    }
    
    public func send(_ closure: (Event) -> Void ) {
        var targetSet: TargetSet<Event>?
        queue.sync { [weak self] in targetSet = self?.targetSet }
        targetSet?.send(closure)
    }
    
    public func removeTarget(_ target: AnyObject) {
        guard target is Event else { return }
        
        queue.async(flags: .barrier) { [weak self] in
            self?.targetSet.removeTarget(target)
        }
    }
    
    public func removeNilTargets() {
        queue.async(flags: .barrier) { [weak self] in
            self?.targetSet.removeNilTargets()
        }
    }
}

