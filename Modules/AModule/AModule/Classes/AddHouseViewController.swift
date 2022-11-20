//
//  AddHouseViewController.swift
//  AModule
//
//  Created by NeroXie on 2022/11/13.
//

import Foundation
import NNModule_swift
import ModuleServices
import SnapKit
import BaseModule
import MBProgressHUD

class AddHouseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Add house"
        view.backgroundColor = .white
        
        let btn = UIButton()
        btn.setTitle("Add House Test", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        btn.backgroundColor = .blue
        btn.addTarget(self, action: #selector(didButtonPressed), for: .touchUpInside)
        view.addSubview(btn)
        btn.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaTop)
            $0.leading.equalToSuperview().offset(16)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(30)
        }
        
        Module.service(of: HouseService.self).houseEvent.addTarget(self)
    }
    
    @objc private func didButtonPressed() {
        MBProgressHUD.showAdded(to: view, animated: true)
        Module.service(of: HouseService.self).addHouse(houseName: "House")
    }
}

extension AddHouseViewController: HouseEvent {
    
    func didAddHouse(_ house: HouseModel) {
        MBProgressHUD.hide(for: view, animated: true)
        navigationController?.popViewController(animated: true)
    }
}
