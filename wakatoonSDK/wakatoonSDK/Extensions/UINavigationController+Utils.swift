//
//  UINavigationController+Utils.swift
//  wakatoonSDK
//
//  Created by bs-mac-4 on 19/12/22.
//

import Foundation
import UIKit


extension UINavigationController {
    func popToViewController(ofClass: AnyClass, animated: Bool = false) {
        if let vc = viewControllers.last(where: { $0.isKind(of: ofClass) }) {
            popToViewController(vc, animated: animated)
        }
    }
    
    func popToViewControllerWithGivenClass(ofClass: AnyClass, animated: Bool = false) {
        if let index = viewControllers.firstIndex(where: { vc in
            return vc.isKind(of: ofClass)
        }) {
            let vc = viewControllers[index-1]
            popToViewController(vc, animated: animated)
        }
        
    }
    
    func containsViewController(ofKind kind: AnyClass) -> Bool {
        return self.viewControllers.contains(where: { $0.isKind(of: kind) })
    }
    
    func popBack(_ count: Int, animated: Bool = false) {
        let viewControllers: [UIViewController] = self.viewControllers
        guard viewControllers.count < count else {
            self.popToViewController(viewControllers[viewControllers.count - count], animated: animated)
            return
        }
    }
}
