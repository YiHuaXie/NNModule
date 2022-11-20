//
//  UserViewController.swift
//  ModuleServices
//
//  Created by NeroXie on 2022/11/15.
//

import Foundation
import BaseModule
import SnapKit
import ModuleServices
import NNModule_swift
import MBProgressHUD
import HandyJSON

public struct UserModel: HandyJSON {
    
    public var uid: String = ""
    
    public var name: String = ""
    
    public init() {}
}

class UserViewController: UIViewController {
    
    private var user = UserModel()
    
    private let userNameLabel = UILabel()
    
    private let userIdLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userNameLabel.textColor = .black
        userNameLabel.text = "User name:"
        userNameLabel.font = .systemFont(ofSize: 20, weight: .medium)
        view.addSubview(userNameLabel)
        userNameLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaTop).offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.centerX.equalToSuperview()
        }
        
        userIdLabel.textColor = .black
        userIdLabel.text = "User id:"
        userIdLabel.font = .systemFont(ofSize: 20, weight: .medium)
        view.addSubview(userIdLabel)
        userIdLabel.snp.makeConstraints {
            $0.top.equalTo(userNameLabel.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.centerX.equalToSuperview()
        }
        
        let btn = UIButton()
        btn.setTitle("Logout", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        btn.backgroundColor = .blue
        btn.addTarget(self, action: #selector(didButtonPressed), for: .touchUpInside)
        view.addSubview(btn)
        btn.snp.makeConstraints {
            $0.top.equalTo(userIdLabel.snp.bottom).offset(40)
            $0.leading.equalToSuperview().offset(16)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(30)
        }
        
        MBProgressHUD.showAdded(to: view, animated: true)
        
        MockServer.shared.getUser { [weak self] result in
            guard let `self` = self else { return }
            
            MBProgressHUD.hide(for: self.view, animated: true)
            
            let user = UserModel.deserialize(from: result)!
            self.userNameLabel.text = "User name: \(user.name)"
            self.userIdLabel.text = "User id: \(user.uid)"
        }
    }
    
    @objc private func didButtonPressed() {
        Module.service(of: LoginService.self).logout()
    }
}
