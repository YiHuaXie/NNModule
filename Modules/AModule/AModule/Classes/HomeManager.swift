//
//  HomeService.swift
//  AModule
//
//  Created by NeroXie on 2020/7/5.
//

import Foundation
import NNModule
import ModuleServices

final class HomeManager: HomeService, RegisterLaunchTaskService {
    
    private var currentIndex = 1
    
    var home: AnyObject = NSObject()
    
    static var keepaliveRegiteredImpl: Bool { true }
    
    required init() {}
    
    func startTask() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.currentIndex = 100
        }
    }
    
    func homeServiceCurrentIndex() -> Int { currentIndex }
    
    func homeServiceTestMethod() { print("asdasdasdasdasd") }
}

