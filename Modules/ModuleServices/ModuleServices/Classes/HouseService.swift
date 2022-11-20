//
//  HouseService.swift
//  ModuleServices
//
//  Created by NeroXie on 2022/11/13.
//

import Foundation
import NNModule_swift
import HandyJSON

public struct HouseModel: HandyJSON {
    
    public init() {}
    
    public var houseId: String = ""
    
    public var houseName: String = ""
}

public protocol HouseService: ModuleFunctionalService {
    
    var houseEvent: EventSet<HouseEvent> { get }
    
    var houseList: [HouseModel] { get }
    
    func addHouse(houseName: String)
    
    func updateHouseList()
}

public protocol HouseEvent {
    
    func didAddHouse(_ house: HouseModel)
    
    func didUpdateHouseList()
}

public extension HouseEvent {
    
    func didAddHouse(_ house: HouseModel) {}
    
    func didUpdateHouseList() {}
}
