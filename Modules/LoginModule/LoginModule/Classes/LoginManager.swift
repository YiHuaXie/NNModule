import Foundation
import ModuleServices
import NNModule_swift
import SnapKit

extension Module.RegisterService {
    
    @objc static func registerLoginService() {
        Module.register(service: LoginService.self, used: LoginManager.self)
    }
}

internal final class LoginManager: NSObject, LoginService {

    static let shared = LoginManager()
    
    static var implInstance: ModuleBasicService { shared }
    
    var isLogin: Bool = false
    
    required override init() { super.init() }
    
    var loginMain: UIViewController {
        UINavigationController(rootViewController: LoginViewController())
    }
    
    func logout() { updateLoginStatus(false) }
    
    func updateLoginStatus(_ loginStatus: Bool) {
        isLogin = loginStatus
        let notification: Notification.Name = loginStatus ? .didLoginSuccess : .didLogoutSuccess
        Module.notificationService.post(name: notification)
    }
}

class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Example App"
        view.backgroundColor = .lightGray
        
        let btn = UIButton(frame: .zero)
        btn.setTitle("Login", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        btn.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        btn.addTarget(self, action: #selector(didButtonPressed), for: .touchUpInside)
        view.addSubview(btn)
        btn.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(30)
        }
    }
    
    @objc private func didButtonPressed() {
        LoginManager.shared.updateLoginStatus(true)
    }
}


