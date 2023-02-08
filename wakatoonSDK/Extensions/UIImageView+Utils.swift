//
//  UIImageView+Utils.swift
//  wakatoonSDK
//
//  Created by bs-mac-4 on 19/12/22.
//

import Foundation
import UIKit

extension UIImageView {
    func setImageTintColor(_ color: UIColor) {
        let tintedImage = self.image?.withRenderingMode(.alwaysTemplate)
        self.image = tintedImage
        self.tintColor = color
    }
}

extension UIImage {
 
    func rotate() -> UIImage {
        var rotatedImage = UIImage()
        guard let cgImage = cgImage else {
            return self
        }
        switch imageOrientation {
            case .right:
                rotatedImage = UIImage(cgImage: cgImage, scale: scale, orientation: .down)
            case .down:
                rotatedImage = UIImage(cgImage: cgImage, scale: scale, orientation: .left)
            case .left:
                rotatedImage = UIImage(cgImage: cgImage, scale: scale, orientation: .up)
            default:
                rotatedImage = UIImage(cgImage: cgImage, scale: scale, orientation: .right)
        }
        
        return rotatedImage
    }
    
    func imageWithColor(color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        color.setFill()
        
        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.setBlendMode(CGBlendMode.normal)
        
        let rect = CGRect(origin: .zero, size: CGSize(width: self.size.width, height: self.size.height))
        context?.clip(to: rect, mask: self.cgImage!)
        context?.fill(rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
}

extension UIImage {
    
    /// Returns a image that fills in newSize
    func resizedImage(newSize: CGSize) -> UIImage? {
        guard size != newSize else { return self }
        
        let hasAlpha = false
        let scale: CGFloat = 0.0
        UIGraphicsBeginImageContextWithOptions(newSize, !hasAlpha, scale)
        
        draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    /// Returns a resized image that fits in rectSize, keeping it's aspect ratio
    /// Note that the new image size is not rectSize, but within it.
    func resizedImageWithinRect(rectSize: CGSize) -> UIImage? {
        let widthFactor = size.width / rectSize.width
        let heightFactor = size.height / rectSize.height
        
        var resizeFactor = widthFactor
        if size.height > size.width {
            resizeFactor = heightFactor
        }
        
        let newSize = CGSize(width: size.width / resizeFactor, height: size.height / resizeFactor)
        let resized = resizedImage(newSize: newSize)
        
        return resized
    }
    
}
