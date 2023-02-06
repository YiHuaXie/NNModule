//
//  Navigator.swift
//  Router
//
//  Created by NeroXie on 2019/1/9.
//

import UIKit

@objc public protocol NavigatorType: NSObjectProtocol {
    
    @objc(pushViewController:from:animated:)
    /// Pushes a matching view controller to the navigation controller stack.
    /// - Parameters:
    ///   - viewController: The view controller to push onto the stack.
    ///   - from: Specify a navigation controller stack.
    ///   - animated: Specify true to animate the transition or false if you do not want the transition to be animated.
    func push(_ viewController: UIViewController, from: UINavigationController?, animated: Bool)
    
    @objc(presentViewController:wrap:from:animated:completion:)
    /// Presents a matching view controller.
    /// - Parameters:
    ///   - viewController: The view controller to display over the current view controller’s content.
    ///   - wrap: The view controller to display has a navigation controller.
    ///   - from: The current view controller.
    ///   - animated: Pass true to animate the presentation.
    ///   - completion: The block to execute after the presentation finishes.
    func present(_ viewController: UIViewController, wrap: UINavigationController.Type?, from: UIViewController?, animated: Bool, completion: (() -> Void)?)
}

public extension NavigatorType {
    
    func push(_ viewController: UIViewController, from: UINavigationController? = nil, animated: Bool = true) {
        push(viewController, from: from, animated: animated)
    }
    
    func present(
        _ viewController: UIViewController,
        wrap: UINavigationController.Type? = nil,
        from: UIViewController? = nil,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        present(viewController, wrap: wrap, from: from, animated: animated, completion: completion)
    }
}

public class Navigator: NSObject, NavigatorType {
    
    public override init() { super.init() }
    
    public func push(_ viewController: UIViewController, from: UINavigationController?, animated: Bool) {
        guard (viewController is UINavigationController) == false else { return }
        guard let navigationController = from ?? UIApplication.topViewController?.navigationController else { return }
        
        navigationController.pushViewController(viewController, animated: animated)
    }
    
    public func present(
        _ viewController: UIViewController,
        wrap: UINavigationController.Type?,
        from: UIViewController?,
        animated: Bool,
        completion: (() -> Void)?
    ) {
        guard let fromViewController = from ?? UIApplication.topViewController else { return }
        
        let viewControllerToPresent: UIViewController
        if let navigationControllerClass = wrap, (viewController is UINavigationController) == false {
            viewControllerToPresent = navigationControllerClass.init(rootViewController: viewController)
        } else {
            viewControllerToPresent = viewController
        }
        
        fromViewController.present(viewControllerToPresent, animated: animated, completion: completion)
    }
}

extension UIApplication {
    
    /// The current application's top most view controller.
    @objc public static var topViewController: UIViewController? {
        let selector = NSSelectorFromString("sharedApplication")
        let sharedApplication = UIApplication.perform(selector)?.takeUnretainedValue() as? UIApplication
        
        guard let currentWindows = sharedApplication?.windows else {
            return nil
        }
        
        var rootViewController: UIViewController?
        for window in currentWindows {
            if let windowRootViewController = window.rootViewController, window.isKeyWindow {
                rootViewController = windowRootViewController
                break
            }
        }
        
        return UIViewController.topViewController(of: rootViewController)
    }
}

fileprivate extension UIViewController {
    
    /// Returns the top view controller based on the given view controller.
    class func topViewController(of viewController: UIViewController?) -> UIViewController? {
        if let presentedViewController = viewController?.presentedViewController {
            return topViewController(of: presentedViewController)
        }
        
        if let tabBarController = viewController as? UITabBarController,
           let selectedViewController = tabBarController.selectedViewController {
            return topViewController(of: selectedViewController)
        }
        
        if let navigationController = viewController as? UINavigationController,
           let visibleViewController = navigationController.visibleViewController {
            return topViewController(of: visibleViewController)
        }
        
        
        if let pageViewController = viewController as? UIPageViewController,
           pageViewController.viewControllers?.count == 1 {
            return topViewController(of: pageViewController.viewControllers?.first)
        }
        
        for subview in viewController?.view?.subviews ?? [] {
            if let childViewController = subview.next as? UIViewController {
                return topViewController(of: childViewController)
            }
        }
        
        return viewController
    }
}
