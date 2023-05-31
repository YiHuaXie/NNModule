//
//  ServiceIdentifier.swift
//  NNModule-swift
//
//  Created by NeroXie on 2023/5/29.
//

import Foundation

struct ServiceIdentifier: Hashable {
    
    let value: String
    
    init(_ aProtocol: Protocol) {
        value = NSStringFromProtocol(aProtocol)
    }
    
    init<Generic>(_ aGenericType: Generic.Type) {
        value = String(reflecting: aGenericType)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
    
    static func == (lhs: ServiceIdentifier, rhs: ServiceIdentifier) -> Bool {
        lhs.value == rhs.value
    }
}
