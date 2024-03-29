import Foundation
import SnapKit

extension NSObject {
    
    public func resourceBundle(of name: String) -> Bundle {
        let bundle = Bundle(for: type(of: self))
        guard let bundleURL = bundle.url(forResource: name, withExtension: "bundle") else {
            return bundle
        }
        
        return Bundle(url: bundleURL) ?? bundle
    }
}

extension UIView {
    
    public var safeAreaTop: ConstraintItem {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.snp.top
        } else {
            return snp.top
        }
    }
    
    public var safeAreaBottom: ConstraintItem {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.snp.bottom
        } else {
            return snp.bottom
        }
    }
}

func isAllScreen() -> Bool {
    if #available(iOS 11, *) {
        guard let window = UIApplication.shared.delegate?.window, let w = window else {
            return false
        }
        
        if w.safeAreaInsets.left > 0 || w.safeAreaInsets.bottom > 0 {
            return true
        }
    }
    
    return false
}

extension CGFloat {
    
    public static var safeAreaBottom: CGFloat { isAllScreen() ? 34 : 0 }
}
