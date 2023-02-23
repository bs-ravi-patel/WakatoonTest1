//
//  UIButton+Utils.swift
//  wakatoonSDK
//
//  Created by bs-mac-4 on 19/12/22.
//

import Foundation
import UIKit


extension UIButton{
    
    func setImageTintColor(_ color: UIColor) {
        let tintedImage = self.imageView?.image?.withRenderingMode(.alwaysTemplate)
        self.setImage(tintedImage, for: .normal)
        self.tintColor = color
    }
    
    func setBackButtonLayout(viewController: UIViewController) {
        let backImage = UIImage(named: "left-arrow", in: Bundle(for: type(of: viewController)), compatibleWith: nil)?.imageWithColor(color: .systemTeal)
        self.setImage(backImage, for: .normal)
        self.setImage(backImage, for: .highlighted)
    }
    
}
