//
//  ExampleViewController.swift
//  AModule
//
//  Created by NeroXie on 2022/11/16.
//

import Foundation
import NNModule_swift

class ExampleViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let tableView = UITableView(frame: .zero, style: .plain)
    
    let data = [
        ("Service bridge test", "cmodule/bridgetest")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Example App"
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 50
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { data.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row].0
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let route = data[indexPath.row].1
        Module.routeService.openRoute(route)
    }
}
