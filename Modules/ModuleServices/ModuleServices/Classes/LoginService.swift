//
//  LoginService.swift
//  ModuleServices
//
//  Created by NeroXie on 2022/11/16.
//

import Foundation
import NNModule_swift

// Login service
public protocol LoginService: ModuleFunctionalService {
    
    /// the main viewController of LoginModule
    var loginMain: UIViewController { get }
    
    var isLogin: Bool { get }

    func logout()
}

public extension Notification.Name {
    
    static var didLoginSuccess: Notification.Name { .init("didLoginSuccess") }
    
    static var didLogoutSuccess: Notification.Name { .init("didLogoutSuccess") }
}
