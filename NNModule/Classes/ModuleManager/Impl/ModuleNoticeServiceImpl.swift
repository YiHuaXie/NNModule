//
//  ModuleNoticeServiceImpl.swift
//  ModuleManager
//
//  Created by NeroXie on 2020/12/30.
//

import Foundation

class ModuleNoticeServiceImpl: ModuleNoticeService {
    
    var stickyMap: [String : Notification] = [:]
    
    required init() {}
}
