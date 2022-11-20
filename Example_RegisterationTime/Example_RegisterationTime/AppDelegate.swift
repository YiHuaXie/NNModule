//
//  AppDelegate.swift
//  Example_RegisterationTime
//
//  Created by NeroXie on 2021/8/16.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        awakeClassMethodsTest()
        jsonClassListTest()
        
        // ignore the case
//        objcGetClassList()
        return true
    }
    
    func awakeClassMethodsTest() {
        let start = CFAbsoluteTimeGetCurrent()
        guard let metaClass: AnyClass = object_getClass(Awake.self) else { return }
        
        var count: UInt32 = 0
        guard let methodList = class_copyMethodList(metaClass, &count) else { return }
        
        let handle = dlopen(nil, RTLD_LAZY)
        let methodInvoke = dlsym(handle, "method_invoke")
        
        for i in 0..<Int(count) {
            let method = methodList[i]
            unsafeBitCast(methodInvoke, to:(@convention(c)(Any, Method)->Void).self)(metaClass, method)
        }
        
        dlclose(handle)
        free(methodList)
        
        let end = CFAbsoluteTimeGetCurrent()
        print("执行时长：\((end-start) * 1000) 毫秒")
    }
    
    func jsonClassListTest() {
        let start = CFAbsoluteTimeGetCurrent()
        for i in 0...1000 {
            if let cls = NSClassFromString("Example_RegisterationTime.TestModel\(i)") as? RegisterService.Type {
                cls.registerService()
            }
        }
        let end = CFAbsoluteTimeGetCurrent()
        print("执行时长：\((end-start) * 1000) 毫秒")
    }
    
    func objcGetClassList() {
        let start = CFAbsoluteTimeGetCurrent()

        let classesCount = objc_getClassList(nil, 0)
        let allClasses = UnsafeMutablePointer<AnyClass>.allocate(capacity: Int(classesCount))
        let autoreleasingAllClasses = AutoreleasingUnsafeMutablePointer<AnyClass>(allClasses)
        let actualClassesCount: Int32 = objc_getClassList(autoreleasingAllClasses, classesCount)
        
        for i in 0 ..< actualClassesCount {
            (allClasses[Int(i)] as? RegisterService.Type)?.registerService()
        }

        let end = CFAbsoluteTimeGetCurrent()
        print("执行时长：\((end-start) * 1000) 毫秒")
    }
}

