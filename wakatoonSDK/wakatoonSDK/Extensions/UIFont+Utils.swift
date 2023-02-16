//
//  UIFont+Utils.swift
//  wakatoonSDK
//
//  Created by bs-mac-4 on 20/12/22.
//

import Foundation
import UIKit

extension UIFont {
    
    static func registerFont(withFilenameString filenameString: String, bundle: Bundle) {
        
        guard let pathForResourceString = bundle.path(forResource: filenameString, ofType: nil) else {
            return
        }
        
        guard let fontData = NSData(contentsOfFile: pathForResourceString) else {
            return
        }
        
        guard let dataProvider = CGDataProvider(data: fontData) else {
            return
        }
        
        guard let font = CGFont(dataProvider) else {
            return
        }
        
        var errorRef: Unmanaged<CFError>? = nil
        if (CTFontManagerRegisterGraphicsFont(font, &errorRef) == false) {
        }
    }
    
    func registerFonts() {
        guard let bundel = Bundle(identifier: WakatoonSDKData.shared.BundelID) else {return}
        UIFont.registerFont(withFilenameString: "Comfortaa-Bold.ttf", bundle: bundel)
        UIFont.registerFont(withFilenameString: "Comfortaa-Light.ttf", bundle: bundel)
        UIFont.registerFont(withFilenameString: "Comfortaa-Medium.ttf", bundle: bundel)
        UIFont.registerFont(withFilenameString: "Comfortaa-Regular.ttf", bundle: bundel)
        UIFont.registerFont(withFilenameString: "Comfortaa-SemiBold.ttf", bundle: bundel)
    }

}

func getFont(size: CGFloat, style: Font) -> UIFont {
    switch style {
        case .Light:
            return UIFont(name: "Comfortaa-Light", size: size) ?? UIFont.systemFont(ofSize: size, weight: .light)
        case .Regular:
            return UIFont(name: "Comfortaa-Regular", size: size) ?? UIFont.systemFont(ofSize: size, weight: .regular)
        case .Medium:
            return UIFont(name: "Comfortaa-Medium", size: size) ?? UIFont.systemFont(ofSize: size, weight: .medium)
        case .Bold:
            return UIFont(name: "Comfortaa-Bold", size: size) ?? UIFont.systemFont(ofSize: size, weight: .bold)
        case .SemiBold:
            return UIFont(name: "Comfortaa-SemiBold", size: size) ?? UIFont.systemFont(ofSize: size, weight: .semibold)
    }
}

enum Font {
    case Light
    case Regular
    case Medium
    case Bold
    case SemiBold
}
