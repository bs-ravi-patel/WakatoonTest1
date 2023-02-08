//
//  WakatoonManager.swift
//  wakatoonSDK
//
//  Created by bs-mac-4 on 09/12/22.
//

import Foundation
import UIKit

public class WakatoonSDK: NSObject {
    
    public var delegate: WakatoonSDKDelegate? {
        didSet {
            WakatoonSDKData.shared.delegate = delegate
        }
    }
    
    override init() {}
    
    public class Builder {
        
        public var instance: WakatoonSDK?
        
        public init(instance: WakatoonSDK? = nil) {
            self.instance = instance
        }
        
        /// create the build
        public func build() -> WakatoonSDK {
            setupLanguageBundel()
            UIFont().registerFonts()
            return instance ?? WakatoonSDK()
        }
        
        /// setup SDK with API Key for API Authentication
        /// USER_ID for users id
        /// PROFILE_ID for user profiles id
        public func initSDK(API_KEY: String, USER_ID: String, PROFILE_ID:String, PROFILE_NAME: String = "") -> Builder {
            WakatoonSDKData.shared.API_KEY = API_KEY
            WakatoonSDKData.shared.USER_ID = USER_ID
            WakatoonSDKData.shared.PROFILE_ID = PROFILE_ID
            if PROFILE_NAME != "" {
                Common.setPreviousName(PROFILE_NAME)
            }
            return self
        }
        
        public func enableDebugMode(_ isEnable: Bool) -> Builder {
            WakatoonSDKData.shared.isDebugEnable = isEnable
            return self
        }
        
        public func setLanguage(_ language: Language) -> Builder {
            WakatoonSDKData.shared.selectedLanguage = language
            return self
        }
        
        private func setupLanguageBundel() {
            guard let bundle = Bundle(identifier: WakatoonSDKData.shared.BundelID), let languagePath = bundle.path(forResource: WakatoonSDKData.shared.selectedLanguage.description(), ofType: "lproj"), let languageBundle = Bundle(path: languagePath) else {
                return
            }
            WakatoonSDKData.shared.selectedLanguageBundel = languageBundle
        }
        
    }
    
    /// Set Profile ID
    /// Set User ID
    ///SET Profile Name
    public func setCurrentWakartist(USER_ID: String, PROFILE_ID: String, PROFILE_NAME: String = "", completion: @escaping((_ isUpdated: Bool)->())) {
        WakatoonSDKData.shared.USER_ID = USER_ID
        WakatoonSDKData.shared.PROFILE_ID = PROFILE_ID
        if PROFILE_NAME != "" {
            Common.setPreviousName(PROFILE_NAME)
        }
        completion(true)
    }
    
    /// Display the SDK Terms and Condition Pop with completion of acceptance result
    public func showTermsAndPrivacy(controller: UINavigationController, completion: @escaping((_ isAccept: Bool)->())) {
        let videoPlayerList = eulaSDKPopUPViewController(nibName: "eulaSDKPopUPViewController", bundle: Bundle(for: eulaSDKPopUPViewController.self))
        videoPlayerList.callBack = { isAccept in
            videoPlayerList.dismiss(animated: false)
            completion(isAccept)
        }
        videoPlayerList.modalPresentationStyle = .overFullScreen
        videoPlayerList.modalTransitionStyle = .crossDissolve
        controller.present(videoPlayerList, animated: true)
    }
    
    /// GET the artwork of the episode
    public func getEpisodeArtwork(storyID: String, seasonID: Int, episodeID: Int, completion: @escaping((_ response: Data?, _ error: Error?)->())) {
        APIManager.shared.getArtWork(storyID: storyID, seasonID: seasonID, episodeId: episodeID, completion: completion)
    }
    
    /// Goto Video Player
    public func launchEpisode(controller: UINavigationController, storyID: String, seasonID: Int, episodeID: Int, totalEpisodes: Int) {
        WakatoonSDKData.shared.currentStoryID = storyID
        WakatoonSDKData.shared.currentSeasonID = seasonID
        WakatoonSDKData.shared.currentEpisodeID = episodeID
        WakatoonSDKData.shared.totalEpisode = totalEpisodes
        let videoPlayerController = VideoPlayerViewController.FromStoryBoard()
        videoPlayerController.isScreenFor = EpisodeDrawnModel().isEpisodeDrawn() ? .DETECTED_LOOP : .INTRO
        controller.navigationBar.isHidden = true
        controller.pushViewController(videoPlayerController, animated: true)
    }
    
    ///GET all suppotedLanguage of SDK on 0
    ///GET currentSelected Language of SDK on 1
    public static func getSupportedLanguages() -> ([String],String) {
        var temp = [String]()
        Language.allCases.forEach({ lang in
            temp.append(lang.description())
        })
        return (temp,WakatoonSDKData.shared.selectedLanguage.description())
    }
    
    ///SET SDK language Defualt will be fr
    public func setLanguage(_ language: Language) {
        WakatoonSDKData.shared.selectedLanguage = language
        guard let bundle = Bundle(identifier: WakatoonSDKData.shared.BundelID), let languagePath = bundle.path(forResource: WakatoonSDKData.shared.selectedLanguage.description(), ofType: "lproj"), let languageBundle = Bundle(path: languagePath) else {
            return
        }
        WakatoonSDKData.shared.selectedLanguageBundel = languageBundle
    }
    
    ///GET the SDK version
    public static func getVersion() -> String {
        return Bundle(identifier: WakatoonSDKData.shared.BundelID)?.infoDictionary?["wakatoonSDKVersion"] as? String ?? ""
    }
    
}

public protocol WakatoonSDKDelegate {
    func videoPlaybackStarted()
    func videoPlaybackStopped()
}
