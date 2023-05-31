//
//  HouseListViewController.swift
//  AModule
//
//  Created by NeroXie on 2022/11/13.
//

import Foundation
import NNModule_swift
import ModuleServices
import SnapKit
import MBProgressHUD

class HouseListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var houseList: [HouseModel] = []
    
    let tableView = UITableView(frame: .zero, style: .plain)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "House list"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Add house",
            style: .done,
            target: self,
            action: #selector(jumpToWebView)
        )
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Cancel",
            style: .done,
            target: self,
            action: #selector(cancel)
        )
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 50
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        let houseImpl = Module.serviceImpl(of: HouseService.self)
        houseImpl.houseEvent.addTarget(self)
        houseList = houseImpl.houseList
        if houseList.isEmpty { MBProgressHUD.showAdded(to: view, animated: true) }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { houseList.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let houseModel = houseList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "id = \(houseModel.houseId), name = \(houseModel.houseName)"
        
        return cell
    }
    
    @objc private func jumpToWebView() {
        AModuleImpl.router.openRoute("house/add")
    }
    
    @objc private func cancel() {
        dismiss(animated: true)
    }
}

extension HouseListViewController: HouseEvent {
    
    func didAddHouse(_ house: HouseModel) {
        houseList = Module.serviceImpl(of: HouseService.self).houseList
        tableView.reloadData()
    }
    
    func didUpdateHouseList() {
        MBProgressHUD.hide(for: view, animated: true)
        houseList = Module.serviceImpl(of: HouseService.self).houseList
        tableView.reloadData()
    }
}
