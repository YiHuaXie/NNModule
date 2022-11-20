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
        
    let tableView = UITableView(frame: .zero, style: .plain)
    
    var dataList: [[(name: String, handler: () -> Void)]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataList = [
            [
                ("Test：https://www.neroxie.com", { URLRouter.default.openRoute("https://www.neroxie.com") }),
                ("Specified link test：https://www.baidu.com", { URLRouter.default.openRoute("https://www.baidu.com") }),
                ("Combine test 1：https://nero.com/111", { URLRouter.default.openRoute("https://nero.com/111?id=1", parameters: ["id": "123"]) }),
                ("Combine test 2：https://nero.com/222", { URLRouter.default.openRoute("https://nero.com/222", parameters: ["id": "123"]) })
            ],
            [
                ("Test 1：module", { URLRouter.default.openRoute("module?id=a") }),
                ("Test 2：module/apage", { URLRouter.default.openRoute("module/apage?id=a", parameters: ["id": "aaa", "name": "nero"]) }),
                ("Test 3：module/bpage", { URLRouter.default.openRoute("module/bpage?id=b", parameters: ["model": NSObject()]) }),
                ("Test 4：module/cpage", { URLRouter.default.openRoute("module/cpage?id=c") }),
            ],
            [
                ("Test 1：module2/111?id=123", { URLRouter(with: URLRouter.default).openRoute("module2/111?id=123") }),
                ("Test 2 (empty super router)：module2/111?id=123", { URLRouter().openRoute("module2/111?id=123") })
            ],
            [
                ("Test 1：nero://aaa/sss/c", { URLRouter.default.openRoute("nero://aaa/sss/c?id=aaa") }),
                ("Test 2：nero://module/apage", { URLRouter.default.openRoute("nero://module/apage") })
            ],
            [
                ("Test 1：module3/main?uid=12345", { URLRouter.default.openRoute("module3/main?uid=12345") }),
                ("Test 2：module3/apage?permission=1&uid=12345", { URLRouter.default.openRoute("module3/apage?permission=1&uid=12345") }),
                ("Test 3：module3/apage?uid=12345", { URLRouter.default.openRoute("module3/apage?uid=12345") }),
                ("Test 4：module3/apage", { URLRouter.default.openRoute("module3/apage") }),
            ],
            [
                ("Test 1：https://redirect.com/main -> redirect/main", { URLRouter.default.openRoute("https://redirect.com/main?id=123") }),
                ("Test 2：redirect/apage -> https://redirect.com/apage", { URLRouter.default.openRoute("redirect/apage?id=123", parameters: ["name": "张三"]) })
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
        case 0: return "Html test"
        case 1: return "Subrouter test"
        case 2: return "Super router forwarding test"
        case 3: return "Scheme test"
        case 4: return "Interceptor test"
        case 5: return "Redirect route test"
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




