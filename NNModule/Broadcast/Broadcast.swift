//
//  Broadcast.swift
//  NNModule-swift
//
//  Created by NeroXie on 2022/4/4.
//

import Foundation

struct WeakTarget: Equatable, Hashable {
    
    private let identifier: ObjectIdentifier
    
    weak var target: AnyObject?
    
    init(_ target: AnyObject) {
        self.target = target
        identifier = ObjectIdentifier(target)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    static func == (lhs: WeakTarget, rhs: WeakTarget) -> Bool {
        lhs.identifier == rhs.identifier
    }
}

struct TargetSet<Event> {
    
    var set = Set<WeakTarget>()
    
    var count: Int { self.set.count }
    
    mutating func addTarget(_ target: AnyObject) {
        guard target is Event else { return }
        
        let member = WeakTarget(target)
        if set.contains(member)  { set.remove(member) }
        set.insert(member)
    }
    
    func send(_ closure: (Event) -> Void ) {
        set.forEach { if let target = $0.target as? Event { closure(target) } }
    }
    
    mutating func removeTarget(_ target: AnyObject) {
        guard target is Event else { return }
        
        set.remove(WeakTarget(target))
    }
    
    mutating func removeNilTargets() {
        set = set.filter { $0.target != nil }
    }
}

public class Multicast<Event> {
    
    private var queue: DispatchQueue
    
    private var targetSet: TargetSet<Event>
    
    public required init(name: String) {
        targetSet = TargetSet<Event>()
        queue = DispatchQueue(label: name, attributes: .concurrent)
    }
    
    public required convenience init() {
        self.init(name: "com.nn.default.Multicast")
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
        queue.sync { [weak self] in self?.targetSet.send(closure) }
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

public class Broadcast {
    
    private var queue: DispatchQueue
    
    private var eventMap: [String: TargetSet<Any>]
    
    public static let `default` = Broadcast()
    
    public required init(name: String) {
        eventMap = [:]
        queue = DispatchQueue(label: name, attributes: .concurrent)
    }
    
    public required convenience init() {
        self.init(name: "com.nn.default.Broadcast")
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
