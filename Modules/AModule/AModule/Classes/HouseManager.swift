//
//  HouseManager.swift
//  ModuleServices
//
//  Created by NeroXie on 2022/11/13.
//

import Foundation
import NNModule_swift
import ModuleServices
import BaseModule

extension Module.Awake {
    
    @objc static func houseManagerAwake() {
        let manager = HouseManager.shared
        Module.notificationService.addObserver(forName: .didLoginSuccess) { [weak manager] _ in
            manager?.houseList = []
            manager?.updateHouseList()
        }.disposed(by: manager)
    }
}

class HouseManager: NSObject, HouseService {
    
    static let shared = HouseManager()
    
    static var implInstance: ModuleBasicService { shared }
    
    private(set) var houseEvent = EventSet<HouseEvent>()
    
    var houseList: [HouseModel] = []
    
    required override init() { super.init() }
    
    func addHouse(houseName: String) {
        MockServer.shared.addHouse(houseName: houseName) { [weak self] result in
            guard let house = HouseModel.deserialize(from: result) else {
                return
            }
            
            self?.houseList.append(house)
            self?.houseEvent.send { $0.didAddHouse(house) }
        }
    }
    
    func updateHouseList() {
        MockServer.shared.getHouseList { [weak self] result in
            let houseList = [HouseModel].deserialize(from: result) as! [HouseModel]
            self?.houseList = houseList
            self?.houseEvent.send { $0.didUpdateHouseList() }
        }
    }
}

