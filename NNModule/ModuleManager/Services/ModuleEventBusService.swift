//
//  ModuleEventBusService.swift
//  NNModule-swift
//
//  Created by NeroXie on 2022/5/31.
//

import Foundation

public protocol ModuleEventBusService: ModuleFunctionalService {

    func register<Event>(_ eventType: Event.Type, target: AnyObject)

    func remove<Event>(_ eventType: Event.Type, target: AnyObject)

    func remove<Event>(_ eventType: Event.Type)
    
    func removeNilTargets<Event>(_ eventType: Event.Type)

    func send<Event>(_ eventType: Event.Type, closure: (Event) -> Void)
}

extension EventBus: ModuleEventBusService {

    public static var serviceImpl: ModuleBasicService { EventBus.default }
}

