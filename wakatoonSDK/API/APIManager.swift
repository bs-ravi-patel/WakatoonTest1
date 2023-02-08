//
//  APIManager.swift
//  wakatoonSDK
//
//  Created by bs-mac-4 on 15/12/22.
//

import Foundation
import Network
import UIKit

class APIManager: NSObject {
    
    static let shared = APIManager()
    private let BaseURL = "https://api.wakatoon.com/waas/"
    enum Endpoints: String {
        case artwork            = "episode/artwork"
        case overlay            = "ui/episode/overlay"
        case extract            = "artwork/extract"
        case extractValidate    = "photo/validate"
        case getVideo           = "stream/link"
    }
    enum ValidationStatus {
        case Yes
        case No
    }
    enum VideoLabel: String {
        case DETECTED_LOOP      = "DETECTED_LOOP"
        case EPISODE            = "EPISODE"
        case INTRO              = "INTRO"
        case DETECTED           = "DETECTED"
    }
    
    //MARK: - GET ARTWORK -
    public func getArtWork(storyID: String, seasonID: Int, episodeId: Int, completion: @escaping((_ response: Data?, _ error: Error?)->())) {
        if let url = URL(string: self.BaseURL + Endpoints.artwork.rawValue + "?userId=\(WakatoonSDKData.shared.USER_ID)&profileId=\(WakatoonSDKData.shared.PROFILE_ID)&storyId=\(storyID)&seasonId=\(seasonID)&episodeId=\(episodeId)") {
            self.makeGetRequest(url: url, completion: completion)
        }
    }
    
    //MARK: - GET OVERLAY -
    public func getOverlayImage(completion: @escaping((_ response: Data?, _ error: Error?)->())) {
        if let url = URL(string: self.BaseURL + Endpoints.overlay.rawValue + "?storyId=\(WakatoonSDKData.shared.currentStoryID)&seasonId=\(WakatoonSDKData.shared.currentSeasonID)&episodeId=\(WakatoonSDKData.shared.currentEpisodeID)") {
            self.makeGetRequest(url: url, completion: completion)
        }
    }
    
    //MARK: - EXTRACT IMAGE
    public func getExtractedImage(image: URL, originalImage: UIImage?, completion: @escaping((_ response: Data?, _ error: Error?)->())) {
        if let url = URL(string: self.BaseURL + Endpoints.extract.rawValue), let uiImage = originalImage {
                
                let parameters = [
                    ["key": "userId", "value": "\(WakatoonSDKData.shared.USER_ID)", "type": "text"],
                    ["key": "profileId", "value": "\(WakatoonSDKData.shared.PROFILE_ID)", "type": "text"],
                    ["key": "storyId", "value": "\(WakatoonSDKData.shared.currentStoryID)", "type": "text"],
                    ["key": "seasonId", "value": "\(WakatoonSDKData.shared.currentSeasonID)", "type": "text"],
                    ["key": "episodeId", "value": "\(WakatoonSDKData.shared.currentEpisodeID)", "type": "text"],
                    ["key": "screenWidth", "value": "\(Int(UIScreen.main.bounds.size.height))", "type": "text"],
                    ["key": "screenHeight", "value": "\(Int(UIScreen.main.bounds.size.width))", "type": "text"],
                    ["key": "overlayDisplayOffsetX", "value": "\((UIScreen.main.bounds.size.width - (uiImage.size.width / UIScreen.main.scale) / 2.0))", "type": "text"],
                    ["key": "overlayDisplayOffsetY", "value": "\((UIScreen.main.bounds.size.width - (uiImage.size.height / UIScreen.main.scale) / 2.0))", "type": "text"],
                    ["key": "overlayDisplayWidth", "value": "\(uiImage.size.width)", "type": "text"],
                    ["key": "overlayDisplayHeight", "value": "\(uiImage.size.height)", "type": "text"],
                    ["key": "photoFile","src": image.absoluteString, "type": "file"]] as [[String : Any]]
                let boundary = generateBoundary()
                let dataBody = getBodyData(parameters: parameters, boundary: boundary)
                makePostRequest(url: url, dataBody: dataBody, boundary: boundary, completion: completion)
           
           
        }
    }
    
    //MARK: - VALIDATE EXTRACT IMAGE
    public func validateExtractImage(photoID: String, status: ValidationStatus, completion: @escaping((_ response: Data?, _ error: Error?)->())) {
        if let url = URL(string: BaseURL + Endpoints.extractValidate.rawValue) {
            let parameters = [
                ["key": "userId", "value": "\(WakatoonSDKData.shared.USER_ID)", "type": "text"],
                ["key": "profileId", "value": "\(WakatoonSDKData.shared.PROFILE_ID)", "type": "text"],
                ["key": "storyId", "value": "\(WakatoonSDKData.shared.currentStoryID)", "type": "text"],
                ["key": "seasonId", "value": "\(WakatoonSDKData.shared.currentSeasonID)", "type": "text"],
                ["key": "episodeId", "value": "\(WakatoonSDKData.shared.currentEpisodeID)", "type": "text"],
                ["key": "status", "value": status == .Yes ? "true" : "false", "type": "text" ]] as [[String : Any]]
            let boundary = generateBoundary()
            let dataBody = getBodyData(parameters: parameters, boundary: boundary)
            makePostRequest(url: url, dataBody: dataBody, boundary: boundary, completion: completion)
        }
    }

    //MARK: - GET OVERVIEW VIDEO
    public func getVideo(label: VideoLabel,name: String? = nil, completion: @escaping((_ response: Data?, _ error: Error?)->())) {
        var urlStr = BaseURL + Endpoints.getVideo.rawValue + "?userId=\(WakatoonSDKData.shared.USER_ID)&profileId=\(WakatoonSDKData.shared.PROFILE_ID)&storyId=\(WakatoonSDKData.shared.currentStoryID)&seasonId=\(WakatoonSDKData.shared.currentSeasonID)&episodeId=\(WakatoonSDKData.shared.currentEpisodeID)&label=\(label.rawValue)&language=\(WakatoonSDKData.shared.selectedLanguage.description())"
        urlStr += "&firstName=\(name ?? "")"
        urlStr = urlStr.replacingOccurrences(of: " ", with: "%20")
        if let url = URL(string: urlStr) {
            makeGetRequest(url: url, completion: completion)
        }
    }
    
    
}

extension APIManager {
    
    private func makeGetRequest(url: URL, completion: @escaping((_ response: Data?, _ error: Error?)->())) {
        if Common.isValidAPIKey() {
            var request = URLRequest(url: url)
            request.addValue(WakatoonSDKData.shared.API_KEY, forHTTPHeaderField: "x-api-key")
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data else {
                    var nsError = NSError()
                    if WakatoonSDKData.shared.isDebugEnable {
                        nsError = NSError(domain: "", code: 0, userInfo: ["error": ErrorModel(errorMessage: error?.localizedDescription, errorType: "Error") as Any])
                    }
                    completion(nil,nsError)
                    return
                }
                if WakatoonSDKData.shared.isDebugEnable {
                    print("response",String(data: data, encoding: .utf8)!)
                }
                if let errorModel: ErrorModel? = Common.decodeDataToObject(data: data), let _ = errorModel?.errorMessage, let _ = errorModel?.errorType {
                    let error = NSError(domain: "", code: 0,userInfo: ["error":errorModel as Any])
                    completion(nil,error)
                }
                do {
                    if let results = try JSONSerialization.jsonObject(with: data) as? [String:Any], results["message"] as? String == "Forbidden" {
                        if WakatoonSDKData.shared.isDebugEnable {
                            print("API KEY is invalid")
                        }
                    } else {
                        completion(data,nil)
                    }
                } catch {
                    completion(data,nil)
                }
            }.resume()
        }
    }
    
    private func makePostRequest(url: URL, dataBody: Data?,boundary: String, completion: @escaping((_ response: Data?, _ error: Error?)->())) {
        if Common.isValidAPIKey() {
            var request = URLRequest(url: url)
            request.addValue(WakatoonSDKData.shared.API_KEY, forHTTPHeaderField: "x-api-key")
            request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            if let bodyData = dataBody {
                URLSession.shared.uploadTask(with: request, from: bodyData) { data, responce, error in
                    guard let data = data else {
                        var nsError = NSError()
                        if WakatoonSDKData.shared.isDebugEnable {
                            nsError = NSError(domain: "", code: 0, userInfo: ["error": ErrorModel(errorMessage: error?.localizedDescription, errorType: "Error") as Any])
                        }
                        completion(nil,nsError)
                        return
                    }
                    if WakatoonSDKData.shared.isDebugEnable {
                        print(String(data: data, encoding: .utf8)!)
                    }
                    if let errorModel: ErrorModel? = Common.decodeDataToObject(data: data), let _ = errorModel?.errorMessage, let _ = errorModel?.errorType {
                        let error = NSError(domain: "", code: 0,userInfo: ["error":errorModel as Any])
                        completion(nil,error)
                    }
                    do {
                        if let results = try JSONSerialization.jsonObject(with: data) as? [String:Any], results["message"] as? String == "Forbidden" {
                            if WakatoonSDKData.shared.isDebugEnable {
                                print("API KEY is invalid")
                            }
                        } else {
                            completion(data,nil)
                        }
                    } catch {
                        completion(data,nil)
                    }
                }.resume()
            }
        }
    }
    
    private func getBodyData(parameters: [[String:Any]], boundary: String) -> Data {
        var body = Data()
        for param in parameters {
            if param["disabled"] == nil {
                let paramName = param["key"]!
                body.append("--\(boundary)\r\n")
                body.append("Content-Disposition:form-data; name=\"\(paramName)\"")
                if param["contentType"] != nil {
                    body.append("\r\nContent-Type: \(param["contentType"] as! String)")
                }
                let paramType = param["type"] as! String
                if paramType == "text" {
                    let paramValue = param["value"] as! String
                    body.append("\r\n\r\n\(paramValue)\r\n")
                } else {
                    do {
                        let paramSrc = param["src"] as! String
                        let fileData = try NSData(contentsOf: URL(string: paramSrc)!) as Data
                        body.append("; filename=\"\(paramSrc)\"\r\n")
                        body.append("Content-Type: image/png\r\n\r\n")
                        body.append(fileData)
                        body.append("\r\n")
                    }catch {
                        if WakatoonSDKData.shared.isDebugEnable {
                            print(#function, error.localizedDescription)
                        }
                    }
                }
            }
        }
        body.append("--\(boundary)--\r\n")
        return body
    }
    
    private func generateBoundary() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
