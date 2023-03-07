
import Foundation

public class CModuleTestA {
    
    public init() {}
    
    public static func testMethod() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            print("\(self) \(#function)")
        }
    }
}

public class CModuleTestB {
    
    public init() {}
    
    public static func testMethod() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            print("\(self) \(#function)")
        }
    }
}

public class CModuleTestC {
    
    public init() {}
    
    public static func testMethod() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            print("\(self) \(#function)")
        }
    }
}

public class CModuleTestD {
    
    public init() {}
    
    public static func testMethod() {
        print("\(self) \(#function)")
    }
}

public class CModuleTestE {
    
    public init() {}
    
    public static func testMethod() {
        print("\(self) \(#function)")
    }
}

public class CModuleTestF {
    
    public init() { print(#function) }
    
    public static func testMethod() {
        print("\(self) \(#function)")
    }
}


