//
//  Example_StickyNotificationTests.swift
//  Example_StickyNotificationTests
//
//  Created by NeroXie on 2021/8/16.
//

import XCTest
@testable import Example_StickyNotification
import NNModule_swift

class Example_StickyNotificationTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBasic() throws {
        let objc1 = NSObject()
        let objc2 = NSObject()
        
        let notification = Notification.Name("notification1")
        let center = NotificationCenter.default
        center.addObserver(forName: notification) {
            print("objc1 receive: \($0)")
        }.disposed(by: objc1)
        
        center.addObserver(forName: notification) {
            print("objc2 receive: \($0)")
        }.disposed(by: objc2)
        
        center.post(name: notification, userInfo: ["id": "123"])
    }
    
    func testSticky() throws {
        let objc1 = NSObject()
        let objc2 = NSObject()
        let objc3 = NSObject()
        let notification = Notification.Name("sticky")
        let center = NotificationCenter.default
        
        center.post(name: notification, isSticky: true, userInfo: ["id": "123"])
        center.addObserver(forName: notification, isSticky: true) {
            print("objc1 receive: \($0)")
        }.disposed(by: objc1)
        
        center.post(name: notification, isSticky: false, userInfo: ["id": "456"])
        center.addObserver(forName: notification, isSticky: true) {
            print("objc2 receive: \($0)")
        }.disposed(by: objc2)

        center.post(name: notification, isSticky: true, userInfo: ["id": "789"])
        center.addObserver(forName: notification, isSticky: true) {
            print("objc3 receive: \($0)")
        }.disposed(by: objc3)
    }
    
    func testQueue() {
        
    }
    
    func testExample() throws {
       
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
