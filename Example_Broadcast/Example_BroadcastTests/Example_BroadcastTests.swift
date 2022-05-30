//
//  Example_BroadcastTests.swift
//  Example_BroadcastTests
//
//  Created by NeroXie on 2021/8/16.
//

import XCTest
@testable import Example_Broadcast
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
    
    func aMethod1() {
        debugPrint("\(self) \(#function)")
    }
    
    func aMethod2() {
        debugPrint("\(self) \(#function)")
    }
    
    func bMethod1() {
        debugPrint("\(self) \(#function)")
    }
    
    func bMethod2() {
        debugPrint("\(self) \(#function)")
    }
}

class BModel: AEvent {
    
    init() {}
    
    func aMethod1() {
        debugPrint("\(self) \(#function)")
    }
    
    func aMethod2() {
        debugPrint("\(self) \(#function)")
    }
}

class Example_BroadcastTests: XCTestCase {

//    var aModel = AModel()
//    
//    var bModel = BModel()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testMulticast() {
        var aModel = AModel()
        var bModel = BModel()
        let aMulticast = Multicast<AEvent>()
        aMulticast.registerTarget(aModel)
        aMulticast.registerTarget(bModel)
        aMulticast.send { $0.aMethod1() }
        aMulticast.send { $0.aMethod2() }
        aModel = AModel()
        aMulticast.send { $0.aMethod1() }
        aMulticast.send { $0.aMethod2() }
        aMulticast.removeNilTargets()
    }
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        var aModel = AModel()
        var bModel = BModel()
        
        Broadcast.default.register(AEvent.self, target: aModel)
        Broadcast.default.register(AEvent.self, target: bModel)
        Broadcast.default.register(BEvent.self, target: aModel)
        
        Broadcast.default.send(AEvent.self) { $0.aMethod1() }
        Broadcast.default.send(AEvent.self) { $0.aMethod2() }
        Broadcast.default.send(BEvent.self) { $0.bMethod1() }
        Broadcast.default.send(BEvent.self) { $0.bMethod2() }

        aModel = AModel()
        Broadcast.default.send(AEvent.self) { $0.aMethod1() }
        Broadcast.default.send(AEvent.self) { $0.aMethod2() }
        
        Broadcast.default.remove(AEvent.self, target: bModel)
        Broadcast.default.send(AEvent.self) { $0.aMethod1() }
        Broadcast.default.send(AEvent.self) { $0.aMethod2() }
        
        Broadcast.default.remove(AEvent.self, target: aModel)
        Broadcast.default.remove(AEvent.self)
        Broadcast.default.removeNilTargets(AEvent.self)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

