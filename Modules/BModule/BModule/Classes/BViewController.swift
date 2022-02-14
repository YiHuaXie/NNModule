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
    }
    
    @objc 
    private func didButtonPressed() {
        let service = Module.service(of: HomeService.self)
        service.homeServiceTestMethod()
        print(service.home)
        print(service.homeServiceCurrentIndex())
    }
}
