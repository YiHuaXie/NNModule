//
//  File.swift
//  AModule
//
//  Created by NeroXie on 2022/3/7.
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

public struct TargetSet<Action> {
    
    var set = Set<WeakTarget>()

    public var count: Int { self.set.count }
    
    public mutating func addTarget(_ target: AnyObject) {
        guard target is Action else { return }
        
        let member = WeakTarget(target)
        if set.contains(member)  { set.remove(member) }
        set.insert(member)
    }
    
    public func send(_ closure: (Action) -> Void ) {
        set.forEach { if let target = $0.target as? Action { closure(target) } }
    }
    
    public mutating func removeAllNilTargets() {
        set = set.filter { $0.target != nil }
    }
    
    public mutating func removeTarget(_ target: AnyObject) {
        guard target is Action else { return }

        set.remove(WeakTarget(target))
    }
}

public class EventBus {
    
    fileprivate static var observersMap: [String: TargetSet<Any>] = [:]

    fileprivate static let queue = DispatchQueue(
        label: "com.nn.default.EventBus",
        attributes: .concurrent
    )
    
    public static func register<Event>(_ eventType: Event.Type, target: AnyObject) {
        guard target is Event else {
            assertionFailure("\(type(of: target)) must conforms to the event: \(eventType)")
           
            return
        }
        
        safeInsert(target: target, with: "\(eventType)")
    }
    
    public static func remove<Event>(_ eventType: Event.Type, target: AnyObject) {
        guard target is Event else { return }
        
        safeRemove(target: target, with: "\(eventType)")
    }

    public static func remove<Event>(_ eventType: Event.Type) {
        safeRemove(key: "\(eventType)")
    }
    
    public static func notify<Event>(_ eventType: Event.Type, closure: (Event) -> Void ) {
        guard let targetSet = safeGetSet(key: "\(eventType)") as? TargetSet<Event> else { return }
        targetSet.send(closure)
    }
            
    static func safeInsert(target: AnyObject, with key: String) {
        queue.async(flags: .barrier) {
            var set = observersMap[key] ?? TargetSet<Any>()
            set.addTarget(target)
            observersMap[key] = set
        }
    }
    
    static func safeRemove(target: AnyObject, with key: String) {
        queue.async(flags: .barrier) {
            if var set = observersMap[key] {
                set.removeTarget(target)
                observersMap[key] = set.count > 0 ? set : nil
            }
        }
    }
    
    static func safeRemove(key: String) {
        queue.async(flags: .barrier) { observersMap.removeValue(forKey: key) }
    }
    
    static func safeGetSet(key: String) -> TargetSet<Any>? {
        var set: TargetSet<Any>?
        queue.sync { set = observersMap[key] }
        
        return set
    }
}
