//
//  Extentions.swift
//  VideoPlayerPod
//
//  Created by bs-mac-4 on 29/11/22.
//

import Foundation
import UIKit
import AVFoundation

extension UIDevice {
    /// Returns `true` if the device has a notch
    var hasNotch: Bool {
        guard let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else { return false }
        if UIDevice.current.orientation.isPortrait {
            return window.safeAreaInsets.top >= 44
        } else {
            return window.safeAreaInsets.left > 0 || window.safeAreaInsets.right > 0
        }
    }
}


extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}

extension UITextField {
    func setLeftPadding(padding: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}
