//
//  Common.swift
//  wakatoonSDK
//
//  Created by bs-mac-4 on 19/12/22.
//

import Foundation
import UIKit
import AVFoundation


class Common {
    
    class func decodeDataToObject<T: Codable>(data : Data?)->T? {
        
        if let dt = data{
            do{
                return try JSONDecoder().decode(T.self, from: dt)
            } catch let DecodingError.dataCorrupted(context) {
                if WakatoonSDKData.shared.isDebugEnable {
                    print(context)
                }
            } catch let DecodingError.keyNotFound(key, context) {
                if WakatoonSDKData.shared.isDebugEnable {
                    print("Key '\(key)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                }
            } catch let DecodingError.valueNotFound(value, context) {
                if WakatoonSDKData.shared.isDebugEnable {
                    print("Value '\(value)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                }
            } catch let DecodingError.typeMismatch(type, context)  {
                if WakatoonSDKData.shared.isDebugEnable {
                    print("Type '\(type)' mismatch:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                }
            } catch {
                if WakatoonSDKData.shared.isDebugEnable {
                    print("error: ", error)
                }
            }
        }
        
        return nil
    }
    
    class func isCameraPermissionGranted(completion: @escaping(_ isGranted:Bool)->()) {
        if AVCaptureDevice.authorizationStatus(for: .video) ==  AVAuthorizationStatus.authorized {
            completion(true)
        } else {
            completion(false)
        }
    }
    
    class func getCameraPermission(completion: @escaping(_ isGranted:Bool)->()) {
        AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted: Bool) -> Void in
            if granted == true {
                completion(true)
            } else {
                completion(false)
            }
        })
    }
    
    class func getPreviousName() -> String? {
        return UserDefaults.standard.string(forKey: "PREVIOUS_NAME")
    }
    
    class func setPreviousName(_ name: String) {
        UserDefaults.standard.set(name, forKey: "PREVIOUS_NAME")
    }
    
    class func isValidAPIKey() -> Bool {
        if WakatoonSDKData.shared.API_KEY.trimmingCharacters(in: .whitespacesAndNewlines).count > 0 {
            return true
        }else {
            if WakatoonSDKData.shared.isDebugEnable {
                print("API KEY is invalid")
            }
            return false
        }
    }
    
}

//MARK: - SAVE IMAGE AND VIDEO INTO DIRECTORY

extension Common {
    
    class func saveImageInTemporaryDirectory(image: UIImage, withName name: String, completion: @escaping((_ url: URL?)->())) {
        let data: NSData = image.jpegData(compressionQuality: 1)! as NSData
        guard let fullPath = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(name) else { completion(nil); return }
        try? data.write(to: fullPath, options: .atomic)
        completion(fullPath)
    }
    

    class func downloadEpisodeFromURL(_ videoLink: String, isFor: APIManager.VideoLabel, loopTimecode: Double?) {

        DispatchQueue.main.asyncAfter(deadline: .now()) {
            guard let videoURL = URL(string: videoLink) else { return }
            DownloadManager(name: UUID().uuidString, url: videoURL).download { percent in
                if WakatoonSDKData.shared.isDebugEnable {
                    print("download percent",percent)
                }
            }.finish { (relativePath) in
                let savedVideoString = WakatoonSDKData.shared.homeDirectoryURL.absoluteString + relativePath
                switch isFor {
                    case .DETECTED_LOOP:
                        VideoCacheModel(savedURLString: savedVideoString).saveCacheVideo(.DETECTED_LOOP_DATA, loopTimecode: loopTimecode)
                        break
                    case .EPISODE:
                        VideoCacheModel(savedURLString: savedVideoString).saveCacheVideo(.EPISODE_DATA, loopTimecode: loopTimecode)
                        break
                    case .INTRO:
                        VideoCacheModel(savedURLString: savedVideoString).saveIntroCacheVideo(loopTimecode: loopTimecode)
                        break
                    case .DETECTED:
                        VideoCacheModel(savedURLString: savedVideoString).saveCacheVideo(.DETECTED_DATA, loopTimecode: loopTimecode)
                }
            }.onError { (error) in
                if let errorCode = error.errorCode, errorCode == -16653 || errorCode == -16655 {
                    if isFor != .EPISODE {
                        downloadEpisodeFromURL(videoLink, isFor: isFor, loopTimecode: loopTimecode)
                    }
                }
            }
        }
        
    }
    
}
