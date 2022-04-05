//
//  Target.swift
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
