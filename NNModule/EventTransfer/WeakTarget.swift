//
//  WeakTarget.swift
//  NNModule-swift
//
//  Created by NeroXie on 2022/11/19.
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
