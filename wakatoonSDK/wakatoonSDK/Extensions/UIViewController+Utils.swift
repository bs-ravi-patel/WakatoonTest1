//
//  UIViewController+Utils.swift
//  wakatoonSDK
//
//  Created by bs-mac-4 on 19/12/22.
//

import Foundation
import UIKit


extension UIViewController {
    
    /// POP UIViewController with animated on/off
    func popViewController(animated: Bool = false) {
        self.navigationController?.popViewController(animated: animated)
    }
    
    @objc func popViewControllerNav(animated: Bool = false) {
        self.navigationController?.popViewController(animated: false)
    }
    
    /// Push UIViewController with animated on/off
    func pushViewController(view: UIViewController, animated: Bool = false) {
        self.navigationController?.pushViewController(view, animated: animated)
    }
    
    func showErrorPopUP(errorModel: ErrorModel?, isCancleShow: Bool = true, isRetryShow: Bool = false, retry: @escaping(()->())) {
        let errorPopUp = ErrorPopupViewController.FromStoryBoard()
        errorPopUp.errorModal = errorModel
        errorPopUp.isRetryShow = isRetryShow
        errorPopUp.isCancleyShow = isCancleShow
        errorPopUp.retryCallBack = {
            retry()
        }
        errorPopUp.modalPresentationStyle = .overFullScreen
        present(errorPopUp, animated: true)
    }
    
    func showLoader() {
        let loader = LoaderViewController.FromStoryBoard()
        loader.modalPresentationStyle = .overFullScreen
        present(loader, animated: false)
    }
    
    func hideLoader() {
        dismiss(animated: false)
    }
    
    func isDarkMode() -> Bool {
        traitCollection.userInterfaceStyle == .dark
    }
 
    func setDeviceOrientation(orientation: UIInterfaceOrientationMask = .landscapeRight) {
        if #available(iOS 16.0, *) {
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: orientation))
        } else {
            UIDevice.current.setValue(orientation.toUIInterfaceOrientation.rawValue, forKey: "orientation")
        }
        UINavigationController.attemptRotationToDeviceOrientation()
    }
    
    static func topMostViewController() -> UIViewController? {
        if #available(iOS 13.0, *) {
            let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
            return keyWindow?.rootViewController?.topMostViewController()
        }
        
        return UIApplication.shared.keyWindow?.rootViewController?.topMostViewController()
    }
    
    func topMostViewController() -> UIViewController? {
        if let navigationController = self as? UINavigationController {
            return navigationController.topViewController?.topMostViewController()
        }
        else if let tabBarController = self as? UITabBarController {
            if let selectedViewController = tabBarController.selectedViewController {
                return selectedViewController.topMostViewController()
            }
            return tabBarController.topMostViewController()
        }
        
        else if let presentedViewController = self.presentedViewController {
            return presentedViewController.topMostViewController()
        }
        
        else {
            return self
        }
    }
    
}
extension UIInterfaceOrientationMask {
    var toUIInterfaceOrientation: UIInterfaceOrientation {
        switch self {
            case .portrait:
                return UIInterfaceOrientation.portrait
            case .portraitUpsideDown:
                return UIInterfaceOrientation.portraitUpsideDown
            case .landscapeRight:
                return UIInterfaceOrientation.landscapeRight
            case .landscapeLeft:
                return UIInterfaceOrientation.landscapeLeft
            default:
                return UIInterfaceOrientation.unknown
        }
    }
}
