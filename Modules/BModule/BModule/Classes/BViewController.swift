//
//  BViewController.swift
//  BModule
//
//  Created by NeroXie on 2020/7/13.
//

import UIKit
import NNModule_swift
import SnapKit
import ModuleServices

class B1ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "B1ViewController"
        view.backgroundColor = .yellow
        
        if Module.service(of: LoginService.self).isLogin {
            let btn = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 30))
            btn.setTitleColor(.black, for: .normal)
            btn.setTitle("Present B2ViewController", for: .normal)
            btn.addTarget(self, action: #selector(didButtonPressed), for: .touchUpInside)
            btn.sizeToFit()
            view.addSubview(btn)
        }
    }
    
    @objc private func didButtonPressed() {
        Module.routeService.openRoute("B2Page", parameters: ["model": self])
    }
}

class B2ViewController: UIViewController {
    
    let operationQueue = OperationQueue()
    
    var aObject = NSObject()
    
    var bObject = NSObject()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "B2 ViewController"
        view.backgroundColor = .white
        
        let btn = UIButton(type: .custom)
        btn.backgroundColor = .lightGray
        btn.setTitle("Get data of HomeService", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.addTarget(self, action: #selector(didButtonPressed), for: .touchUpInside)
        view.addSubview(btn)
        btn.snp.makeConstraints {
            $0.top.equalToSuperview().offset(100)
            $0.centerX.equalToSuperview()
        }
        
        let btn2 = UIButton(type: .custom)
        btn2.backgroundColor = .lightGray
        btn2.setTitle("test sticky notification", for: .normal)
        btn2.setTitleColor(.black, for: .normal)
        btn2.addTarget(self, action: #selector(didButtonPressed2), for: .touchUpInside)
        view.addSubview(btn2)
        btn2.snp.makeConstraints {
            $0.top.equalTo(btn.snp.bottom).offset(50)
            $0.centerX.equalToSuperview()
        }
        
        Module.notificationService
            .observe(name: "testSticky")  { notification in
                let value = notification.object as? String ?? ""
                print("===== a object =====\nreceive thread: \(Thread.current)\nreceive notification: \(value)\n====================")
            }
            .disposed(by: aObject)
    }
    
    @objc
    private func didButtonPressed() {
        let service = Module.service(of: HomeService.self)
        service.homeServiceTestMethod()
        print(service.home)
        print(service.homeServiceCurrentIndex())
    }
    
    @objc
    private func didButtonPressed2() {
        debugPrint("send thread: \(Thread.current)")
        Module.notificationService.post(name: "testSticky", object: "nero1", isSticky: true)
        
        bObject = NSObject()
        Module.notificationService
            .observe(name: "testSticky", isSticky: true, queue: operationQueue)  { notification in
                let value = notification.object as? String ?? ""
                print("===== b object =====\nreceive thread: \(Thread.current)\nreceive notification: \(value)\n====================")
            }
            .disposed(by: bObject)
        
        DispatchQueue.global().async {
            debugPrint("send thread: \(Thread.current)")
            Module.notificationService.post(name: "testSticky", object: "nero2")
        }
    }
}
