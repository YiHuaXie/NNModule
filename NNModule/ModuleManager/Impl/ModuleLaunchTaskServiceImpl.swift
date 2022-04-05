//
//  ModuleLaunchTaskServiceImpl.swift
//  ModuleManager
//
//  Created by NeroXie on 2020/11/19.
//

import Foundation

class ModuleLaunchTaskServiceImpl: ModuleLaunchTaskService {
    
    private var syncMainTasks: [RegisterLaunchTaskService] = []
    
    private var asyncMainTasks: [RegisterLaunchTaskService] = []
    
    private var asyncGlobalTasks: [RegisterLaunchTaskService] = []
    
    required init() {}
    
    func addRegister(_ register: RegisterLaunchTaskService.Type) {
        guard let impl = Module.registerImpl(of: register) as? RegisterLaunchTaskService else {
            return
        }
        
        switch impl.runMode {
        case .asynOnGlobal: asyncGlobalTasks.append(impl)
        case .asyncOnMain: asyncMainTasks.append(impl)
        case .syncOnMain: syncMainTasks.append(impl)
        }
    }
    
    func execute() {
        execute(tasks: syncMainTasks)
        
        DispatchQueue.main.async { self.execute(tasks: self.asyncMainTasks) }
        
        DispatchQueue.global().async { self.execute(tasks: self.asyncGlobalTasks) }
    }
    
    private func execute(tasks: [RegisterLaunchTaskService]) {
        let sortedTasks = tasks.sorted { $0.priority.rawValue > $1.priority.rawValue }
        
        sortedTasks.forEach { $0.startTask() }
    }
    
}
