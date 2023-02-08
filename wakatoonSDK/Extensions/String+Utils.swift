//
//  String+Utils.swift
//  wakatoonSDK
//
//  Created by bs-mac-4 on 19/12/22.
//

import Foundation
import UIKit

extension String {
    
    var localized: String {
        guard let languageBundle = WakatoonSDKData.shared.selectedLanguageBundel else {return self}
        return NSLocalizedString(self, tableName: nil, bundle: languageBundle, value: "", comment: "")
    }
    
    func attributedStringFromHTML(completionBlock:(NSAttributedString?) ->()) {
        guard let data = self.data(using: .utf8) else {
            return completionBlock(nil)
        }

        let options = [NSAttributedString.DocumentReadingOptionKey.documentType : NSAttributedString.DocumentType.html,
                       NSAttributedString.DocumentReadingOptionKey.characterEncoding: NSNumber(value:NSUTF8StringEncoding)] as [NSAttributedString.DocumentReadingOptionKey : Any]
        do {
            let attr = try NSAttributedString(data: data, options: options, documentAttributes: nil)
            completionBlock(attr)
        } catch {
            print(error.localizedDescription)
        }
    }

    func format(strings: [String],
                       boldFont: UIFont = UIFont.boldSystemFont(ofSize: 14),
                       boldColor: UIColor = UIColor.blue,
                       inString string: String,
                       font: UIFont = UIFont.systemFont(ofSize: 14),
                       color: UIColor = UIColor.black) -> NSAttributedString {
        let attributedString =
        NSMutableAttributedString(string: string,
                                  attributes: [
                                    NSAttributedString.Key.font: font,
                                    NSAttributedString.Key.foregroundColor: color])
        let boldFontAttribute = [NSAttributedString.Key.font: boldFont, NSAttributedString.Key.foregroundColor: boldColor]
        for bold in strings {
            attributedString.addAttributes(boldFontAttribute, range: (string as NSString).range(of: bold))
        }
        return attributedString
    }
    
}

extension UILabel {
    func indexOfAttributedTextCharacterAtPoint(point: CGPoint) -> Int {
        assert(self.attributedText != nil, "This method is developed for attributed string")
        let textStorage = NSTextStorage(attributedString: self.attributedText!)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        let textContainer = NSTextContainer(size: self.frame.size)
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = self.numberOfLines
        textContainer.lineBreakMode = self.lineBreakMode
        layoutManager.addTextContainer(textContainer)
        
        let index = layoutManager.characterIndex(for: point, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return index
    }
}

