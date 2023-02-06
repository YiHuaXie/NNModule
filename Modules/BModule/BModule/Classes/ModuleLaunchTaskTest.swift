//
//  ModuleLaunchTaskTest.swift
//  BModule
//
//  Created by NeroXie on 2022/11/17.
//

import Foundation
import NNModule_swift

final class ModuleLaunchTaskTest: NSObject, RegisterLaunchTaskService {
    
    static var keepaliveRegiteredImpl: Bool { true }
    
    required override init() { super.init() }
    
    func startTask() {
        let className = NSStringFromClass(type(of: self))
        print("\(className) start task in thread \(Thread.current)")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            print("\(className) finish task")
        }
    }
}
