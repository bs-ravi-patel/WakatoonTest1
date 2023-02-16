//
//  WakatoonSDKData.swift
//  wakatoonSDK
//
//  Created by bs-mac-4 on 20/12/22.
//

import Foundation
import UIKit

public class WakatoonSDKData {
    
    static var shared = WakatoonSDKData()
    let BundelID = "com.etpl.wakatoonSDK"
    var delegate: WakatoonSDKDelegate!
    
    var API_KEY: String = ""
    var USER_ID: String = ""
    var PROFILE_ID: String = ""
    
    var isDebugEnable: Bool = false
    
    var selectedLanguage: Language = .fr
    var selectedLanguageBundel: Bundle?
    
    let themeColor = UIColor(red: 98/255.0, green: 201/255.0, blue: 200/255.0, alpha: 1.0)
    
    var currentStoryID: String = ""
    var currentEpisodeID: Int = 0
    var currentSeasonID: Int = 0
    var totalEpisode: Int = 0
    
    internal let homeDirectoryURL = URL(fileURLWithPath: NSHomeDirectory())
    var nextEpisodeDelegate: NextPlayEpisodeDelegate?
    
    let termsURL = "https://www.wakatoon.com/fr/mentions-legales"
    let privacyPolicyURL = "https://www.wakatoon.com/fr/politique-de-confidentialité/"
}

public enum Language : CaseIterable {
    case en
    case fr
    
    public func description() -> String {
        switch self {
            case .en:
                return "en"
            case .fr:
                return "fr"
        }
    }
}

