//
//  ViewController.swift
//  Example_URLRouter
//
//  Created by NeroXie on 2021/8/15.
//

import UIKit
import NNModule_swift
import SnapKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let routeUtils = RouteUtils()
    
    let tableView = UITableView(frame: .zero, style: .plain)
    
    var dataList: [[(name: String, handler: () -> Void)]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        routeUtils.registerRoutes()
        
        dataList = [
            [
                ("测试1：https://www.baidu.com", { URLRouter.default.openRoute("https://www.baidu.com") }),
                ("测试2：https://www.neroxie.com", { URLRouter.default.openRoute("https://www.neroxie.com") }),
                ("测试3：https://nero.com/111", { URLRouter.default.openRoute("https://nero.com/111") }),
                ("测试4：https://nero.com/222", { URLRouter.default.openRoute("https://nero.com/222") }),
                ("测试5：https://nero.com/333", { URLRouter.default.openRoute("https://nero.com/333") })
            ],
            [
                ("测试1：module/apage", { URLRouter.default.openRoute("module/apage?id=a", parameters: ["id": "aaa", "name": "nero"]) }),
                ("测试2：module/bpage", { URLRouter.default.openRoute("module/bpage?id=b") }),
                ("测试3：module/cpage", { URLRouter.default.openRoute("module/cpage?id=c", parameters: ["model": NSObject()]) }),
                ("测试4：dpage", { URLRouter.default.openRoute("dpage") })
            ],
            [
                ("测试1：nero://aaa/sss/c", { URLRouter.default.openRoute("nero://aaa/sss/c?id=aaa") }),
                ("测试2：nero://module/apage", { URLRouter.default.openRoute("nero://module/apage") })
            ],
            [
                ("测试1：https://test.com/111 -> module2/apage", { URLRouter.default.openRoute("https://test.com/111") }),
                ("测试2：module2/bpage -> https://test.com/222", { URLRouter.default.openRoute("module2/bpage") })
            ]
        ]
        
        view.backgroundColor = .white
        view.addSubview(tableView)
        tableView.rowHeight = 50
        tableView.dataSource = self
        tableView.delegate = self
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int { dataList.count }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let data: [(name: String, handler: () -> Void)] = dataList[section]
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data: [(name: String, handler: () -> Void)] = dataList[indexPath.section]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row].name
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data: [(name: String, handler: () -> Void)] = dataList[indexPath.section]
        let handler = data[indexPath.row].handler
        handler()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Html 测试"
        case 1: return "Native 测试"
        case 2: return "Scheme 测试"
        case 3: return "重定向测试"
        default: return nil
        }
    }
}

class RouterAViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .red
    }
}

class RouterBViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .yellow
    }
}




