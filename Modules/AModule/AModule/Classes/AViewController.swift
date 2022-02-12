//
//  AViewController.swift
//  AModule
//
//  Created by NeroXie on 2020/7/20.
//

import UIKit
import NNModule
import ModuleServices

class A1ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "A1ViewController"
        view.backgroundColor = .red
        
        let btn = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 30))
        btn.setTitle("Jump To A2", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = .white
        btn.addTarget(self, action: #selector(didButtonPressed), for: .touchUpInside)
        btn.sizeToFit()
        view.addSubview(btn)
        
        let btn2 = UIButton(frame: CGRect(x: 100, y: 200, width: 100, height: 30))
        btn2.setTitle("Exit", for: .normal)
        btn2.setTitleColor(.black, for: .normal)
        btn2.backgroundColor = .white
        btn2.addTarget(self, action: #selector(exitApp), for: .touchUpInside)
        btn2.sizeToFit()
        view.addSubview(btn2)
    }
    
    @objc private func didButtonPressed() {
        Module.routeService.openRoute("A2Page", parameters: ["model": self])
    }
    
    @objc private func exitApp() {
        Module.service(of: LoginService.self).updateLoginStatus(with: false)
    }
}


class A2ViewController: UIViewController {
    
    private var btn = UIButton(type: .custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
        navigationItem.title = "A2 ViewController"
        view.backgroundColor = .orange
        
        let btn = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 30))
        btn.backgroundColor = UIColor.white
        btn.setTitleColor(.black, for: .normal)
        btn.setTitle("Open the Web page", for: .normal)
        btn.addTarget(self, action: #selector(didButtonPressed), for: .touchUpInside)
        btn.sizeToFit()
        view.addSubview(btn)
    }
    
    @objc
    private func didButtonPressed() {
        Module.routeService.openRoute("https://www.baidu.com")
    }
}

class A3ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
        navigationItem.title = "A3 ViewController"
        view.backgroundColor = .blue
    }
}
