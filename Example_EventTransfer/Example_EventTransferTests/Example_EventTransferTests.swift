//
//  Example_EventTransferTests.swift
//  Example_EventTransferTests
//
//  Created by NeroXie on 2021/8/16.
//

import XCTest
@testable import Example_EventTransfer
import NNModule_swift

protocol AEvent {
    
    func aMethod1()
    
    func aMethod2()
}

protocol BEvent {
    
    func bMethod1()
    
    func bMethod2()
}

class AModel: AEvent, BEvent {
    
    init() {}
    
    deinit { debugPrint("\(self) \(#function)") }
    
    func aMethod1() { debugPrint("\(self) \(#function)") }
    
    func aMethod2() { debugPrint("\(self) \(#function)") }
    
    func bMethod1() { debugPrint("\(self) \(#function)") }
    
    func bMethod2() { debugPrint("\(self) \(#function)") }
}

class BModel: AEvent {
    
    init() {}
    
    deinit { debugPrint("\(self) \(#function)") }
    
    func aMethod1() { debugPrint("\(self) \(#function)") }
    
    func aMethod2() { debugPrint("\(self) \(#function)") }
}

class Example_EventTransferTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testEventSet() {
        var aModel = AModel()
        var bModel = BModel()
        let aEventSet = EventSet<AEvent>()
        aEventSet.registerTarget(aModel)
        aEventSet.registerTarget(bModel)
        aEventSet.send { $0.aMethod1() }
        aEventSet.send { $0.aMethod2() }
        aModel = AModel()
        aEventSet.send { $0.aMethod1() }
        aEventSet.send { $0.aMethod2() }
        aEventSet.removeNilTargets()
    }
    
    func testEventBus() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let evnetBus = EventBus.default
        var aModel = AModel()
        var bModel = BModel()
        
        evnetBus.register(AEvent.self, target: aModel)
        evnetBus.register(AEvent.self, target: bModel)
        evnetBus.register(BEvent.self, target: aModel)
        
        evnetBus.send(AEvent.self) { $0.aMethod1() }
        evnetBus.send(AEvent.self) { $0.aMethod2() }
        evnetBus.send(BEvent.self) { $0.bMethod1() }
        evnetBus.send(BEvent.self) { $0.bMethod2() }

        aModel = AModel()
        evnetBus.send(AEvent.self) { $0.aMethod1() }
        evnetBus.send(AEvent.self) { $0.aMethod2() }
        
        evnetBus.remove(AEvent.self, target: bModel)
        evnetBus.send(AEvent.self) { $0.aMethod1() }
        evnetBus.send(AEvent.self) { $0.aMethod2() }
        
        evnetBus.remove(AEvent.self, target: aModel)
        evnetBus.remove(AEvent.self)
        evnetBus.removeNilTargets(AEvent.self)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

