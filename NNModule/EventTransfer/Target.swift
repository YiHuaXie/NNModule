//
//  Target.swift
//  NNModule-swift
//
//  Created by NeroXie on 2022/5/31.
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
