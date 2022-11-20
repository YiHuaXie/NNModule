import NNModule_swift
import BaseModule
import ESTabBarController_swift

public class TabBarController: ESTabBarController {
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabbar()
        
        delegate = self
        
        Module.tabService.setupTabBarController(with: self)
        viewControllers = Module.tabService.tabBarItemMeta.map { $0.viewController }
    }
    
    // MARK: - Private Method
    
    fileprivate func setupTabbar() {
        let bundle = resourceBundle(of: "TabBarController")
        let transparent = UIImage(named: "transparent", in: bundle, compatibleWith: nil)
        if #available(iOS 13.0, *) {
            let tabAppearance = UITabBarAppearance()
            tabAppearance.shadowImage = transparent
            tabAppearance.backgroundImage = UIImage()
            tabBar.standardAppearance = tabAppearance
        } else {
            tabBar.shadowImage = transparent
            tabBar.backgroundImage = UIImage()
        }
        
        let container = UIView(frame: CGRect(x: 0, y: -21, width: UIScreen.main.bounds.width, height: .safeAreaBottom + 70))
        tabBar.insertSubview(container, at: 0)
        
        let leftCapInsets = UIEdgeInsets(top: 21, left: 0, bottom: 0, right: 50)
        let leftImage = UIImage(named: "tabbar_background_left", in: bundle, compatibleWith: nil)?
            .resizableImage(withCapInsets: leftCapInsets, resizingMode: .stretch)
        let leftImageView = UIImageView(image: leftImage)
        leftImageView.frame = CGRect(x: 0, y: 0, width: container.width / 2.0, height: container.height)
        container.addSubview(leftImageView)
        
        let rightCapInsets = UIEdgeInsets(top: 21, left: 50, bottom: 0, right: 0)
        let rightImage = UIImage(named: "tabbar_background_right", in: bundle, compatibleWith: nil)?
            .resizableImage(withCapInsets: rightCapInsets, resizingMode: .stretch)
        let rightImageView = UIImageView(image: rightImage)
        rightImageView.frame = CGRect(x: container.width / 2.0, y: 0, width: container.width / 2.0, height: container.height)
        container.addSubview(rightImageView)
    }
}

extension TabBarController: UITabBarControllerDelegate {
    
    public func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let impl = Module.tabService.impl(in: tabBarController, of: viewController)
        return impl?.tabBarController?(tabBarController, shouldSelect: viewController) ?? true
    }
    
    public func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let impl = Module.tabService.impl(in: tabBarController, of: viewController)
        impl?.tabBarController?(tabBarController, didSelect: viewController)
    }
}

public class NormalTabBarItemContentView: ESTabBarItemContentView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        textColor = .black.withAlphaComponent(0.7)
        highlightTextColor = .black
        
        iconColor = .black.withAlphaComponent(0.7)
        highlightIconColor = .black
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    public override func updateLayout() {
        super.updateLayout()
        
        titleLabel.font = .systemFont(ofSize: 10, weight: .medium)
    }
}

public class LargeTabBarItemContentView: ESTabBarItemContentView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        insets = UIEdgeInsets.init(top: -10, left: 0, bottom: 0, right: 0)
        
        textColor = .black.withAlphaComponent(0.7)
        highlightTextColor = .black
        
        renderingMode = .alwaysOriginal
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    public override func updateLayout() {
        super.updateLayout()
        
        imageView.sizeToFit()
        imageView.centerX = width / 2.0
        imageView.y = 0
        
        titleLabel.font = .systemFont(ofSize: 10, weight: .medium)
        titleLabel.sizeToFit()
        titleLabel.centerX = width / 2.0
        titleLabel.y = imageView.frame.maxY + 5
    }
}

// MARK: - Frame
public extension UIView {
    
    var origin: CGPoint {
        set {
            var tmp = frame
            tmp.origin = newValue
            frame = tmp
        }
        get { return frame.origin }
    }
    
    var x: CGFloat {
        set {
            var tmp = frame
            tmp.origin.x = newValue
            frame = tmp
        }
        get { return frame.origin.x }
    }
    
    var y: CGFloat {
        set {
            var tmp = frame
            tmp.origin.y = newValue
            frame = tmp
        }
        get { return frame.origin.y }
    }
    
    var size: CGSize {
        set {
            var tmp = frame
            tmp.size = newValue
            frame = tmp
        }
        get { return frame.size }
    }
    
    var width: CGFloat {
        set {
            var tmp = frame
            tmp.size.width = newValue
            frame = tmp
        }
        get { return frame.size.width }
    }
    
    var height: CGFloat {
        set {
            var tmp = frame
            tmp.size.height = newValue
            frame = tmp
        }
        get { return frame.size.height }
    }
    
    var centerX: CGFloat {
        set {
            var tmp = center
            tmp.x = newValue
            center = tmp
        }
        get { return center.x }
    }
    
    var centerY: CGFloat {
        set {
            var tmp = center
            tmp.y = newValue
            center = tmp
        }
        get { return center.y }
    }
}
