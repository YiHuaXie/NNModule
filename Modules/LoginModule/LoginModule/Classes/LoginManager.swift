import Foundation
import ModuleServices
import NNModule_swift

extension Module.RegisterService {
    
    @objc static func registerLoginService() {
        Module.register(service: LoginService.self, used: LoginManager.self)
    }
}

internal final class LoginManager: LoginService {

    static let shared = LoginManager()
    
    static var implInstance: LoginManager { shared }
    
    var isLogin: Bool = false
    
    var eventSet = EventSet<LoginEvent>()
    
    required init() {}
    
    var loginMain: UIViewController { LoginViewController() }
    
    func updateLoginStatus(with login: Bool) {
        let impl = Module.service(of: LoginService.self)
        isLogin = login
        if isLogin {
            Module.notificationService.post(name: LoginNotification.didLoginSuccess.rawValue)
            impl.eventSet.send { $0.didLoginSuccess() }
        } else {
            Module.notificationService.post(name: LoginNotification.didLogoutSuccess.rawValue)
            impl.eventSet.send { $0.didLogoutSuccess() }
        }
    }
}

class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "LoginViewController"
        view.backgroundColor = .lightGray
        
        let btn = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 30))
        btn.setTitle("Login", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = .white
        btn.addTarget(self, action: #selector(didButtonPressed), for: .touchUpInside)
        btn.sizeToFit()
        view.addSubview(btn)
    }
    
    @objc private func didButtonPressed() {
        Module.service(of: LoginService.self).updateLoginStatus(with: true)
    }
}


