//
//  ModuleEventBusService.swift
//  NNModule-swift
//
//  Created by NeroXie on 2022/4/4.
//

import Foundation

public protocol ModuleEventBusService: ModuleFunctionalService {
    
    func register<Event>(_ eventType: Event.Type, target: AnyObject)
    
    func remove<Event>(_ eventType: Event.Type, target: AnyObject)
    
    func remove<Event>(_ eventType: Event.Type)
    
    func notify<Event>(_ eventType: Event.Type, closure: (Event) -> Void)
}

//extension EventBus: ModuleEventBusService {
//
//    public static var serviceImpl: ModuleBasicService { EventBus.default }
//}
