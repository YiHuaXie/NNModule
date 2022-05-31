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
    
    var eventSet: EventSet<LoginEvent> { get }
    
    func updateLoginStatus(with login: Bool)
    
}

/// The notification of LoginModule
public enum LoginNotification: String {
    
    case didLoginSuccess
    
    case didLogoutSuccess
}

public protocol LoginEvent {
    
    func didLoginSuccess()
    
    func didLogoutSuccess()
}

// other functional services



