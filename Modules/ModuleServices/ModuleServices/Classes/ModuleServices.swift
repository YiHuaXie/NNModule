import NNModule_swift

// Home service
public protocol HomeService: ModuleFunctionalService {
    
    func homeServiceCurrentIndex() -> Int
    
    func homeServiceTestMethod()
    
    var home: AnyObject { get }
}

// Login service
public protocol LoginService: ModuleFunctionalService {
    
    /// the main viewController of LoginModule
    var loginMain: UIViewController { get }
    
    var isLogin: Bool { get }
    
    func updateLoginStatus(with login: Bool)
}

/// The notification of LoginModule
public enum LoginNotification: String {
    
    case didLoginSuccess
    
    case didLogoutSuccess
}

// other functional services



