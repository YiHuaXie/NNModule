//
//  MockService.swift
//  BaseModule
//
//  Created by NeroXie on 2022/11/13.
//

import Foundation

public class MockServer {
    
    private lazy var queue = DispatchQueue(label: "request_queue")
    
    private var user: [String: String] = [:]
        
    private var houseList: [String: String] = [:]
    
    public static let shared = MockServer()
    
    public init() { reset() }
    
    public func updateUserName(_ name: String, completion: @escaping ([String: String]?) -> Void) {
        if name.isEmpty {
            DispatchQueue.main.async { completion(nil) }
            return
        }
        
        let workItem = DispatchWorkItem.init { [weak self] in
            self?.user["name"] = name
            let data = self?.user
            DispatchQueue.main.async { completion(data) }
        }
        
        queue.asyncAfter(deadline: .now() + 1, execute: workItem)
    }
    
    public func getUser(with completion: @escaping ([String: String]) -> Void) {
        let workItem = DispatchWorkItem.init { [weak self] in
            let data = self?.user ?? [:]
            DispatchQueue.main.async { completion(data) }
        }
        
        queue.asyncAfter(deadline: .now() + 1.5, execute: workItem)
    }
    
    public func addHouse(houseName: String, completion: @escaping ([String: String]?) -> Void) {
        if houseName.isEmpty {
            DispatchQueue.main.async { completion(nil) }
            return
        }

        let workItem = DispatchWorkItem.init { [weak self] in
            let houseId = "\(Date().timeIntervalSince1970)".replacingOccurrences(of: ".", with: "")
            self?.houseList[houseId] = houseName
            let data = ["houseId": houseId, "houseName": houseName]
            DispatchQueue.main.async { completion(data) }
        }

        queue.asyncAfter(deadline: .now() + 1, execute: workItem)
    }
    
    public func getHouseList(with completion: @escaping ([[String: String]]) -> Void) {
        let workItem = DispatchWorkItem.init { [weak self] in
            let data = self?.houseList
                .map { ["houseId": $0, "houseName": $1] }
                .sorted(by: { $0["houseId"]! < $1["houseId"]! })
            DispatchQueue.main.async { completion(data ?? []) }
        }
        
        queue.asyncAfter(deadline: .now() + 1.5, execute: workItem)
    }
    
    public func getRedirectRoutes(with completion: @escaping ([String: String]) -> Void) {
        let workItem = DispatchWorkItem.init {
            DispatchQueue.main.async { completion(["https://www.baidu.com": "https://www.neroxie.com"]) }
        }
        
        queue.asyncAfter(deadline: .now() + 1.5, execute: workItem)
    }
    
    public func reset() {
        user = ["uid": "12345", "name": "Nero"]
        
        houseList = [:]
        for i in 1...4 {
            let houseId = "\(Int(Date().timeIntervalSince1970 * 1000000))"
            houseList[houseId] = "House \(i)"
        }
    }
}
