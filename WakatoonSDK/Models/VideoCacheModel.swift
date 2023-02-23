//
//  VideoCacheModel.swift
//  wakatoonSDK
//
//  Created by bs-mac-4 on 13/01/23.
//

import Foundation


struct VideoCacheModel: Codable {
    
    var userID: String?
    var profileID: String?
    var storyID: String?
    var seasonID: Int?
    var episodeId: Int?
    var savedFileName: String?
    var loopTimecode: Double?
    var userName: String?
    
    static func == (lhs: VideoCacheModel, rhs: VideoCacheModel) -> Bool {
        return (lhs.userID == rhs.userID && lhs.profileID == rhs.profileID && lhs.storyID == rhs.storyID && lhs.seasonID == rhs.seasonID && lhs.episodeId == rhs.episodeId)
    }
    
    static func equlsIntroModel(lhs: VideoCacheModel, rhs: VideoCacheModel) -> Bool {
        return (lhs.storyID == rhs.storyID && lhs.seasonID == rhs.seasonID && lhs.episodeId == rhs.episodeId)
    }
    
    public enum CacheFor: String {
        case DETECTED_LOOP_DATA = "DETECTED_LOOP_DATA"
        case EPISODE_DATA       = "EPISODE_DATA"
        case DETECTED_DATA      = "DETECTED_DATA"
    }
    
}

//MARK: - DETECTED_LOOP VIDEO
extension VideoCacheModel {
    
    func isVideoCached(_ cacheFor: CacheFor) -> (Bool, String?, Double?) {
        if let episodeCacheModelArr: [VideoCacheModel] = UserDefaults.standard.getObject(forKey: cacheFor.rawValue), let cacheModel = episodeCacheModelArr.filter({ model in
            return (model.userID == WakatoonSDKData.shared.USER_ID && model.profileID == WakatoonSDKData.shared.PROFILE_ID && model.storyID == WakatoonSDKData.shared.currentStoryID && model.seasonID == WakatoonSDKData.shared.currentSeasonID && model.episodeId == WakatoonSDKData.shared.currentEpisodeID)
        }).first, let cacheName = cacheModel.savedFileName, let cacheURLString = self.getFilePath(name: cacheName) {
            return (true, cacheURLString, cacheModel.loopTimecode)
        } else {
            return (false, nil, nil)
        }
    }
    
    func saveCacheVideo(_ cacheFor: CacheFor, loopTimecode: Double?) {
        if var episodeCacheModelArr: [VideoCacheModel] = UserDefaults.standard.getObject(forKey: cacheFor.rawValue) {
            if let index = episodeCacheModelArr.firstIndex(where: { cacheModel in
                return cacheModel == VideoCacheModel(userID: WakatoonSDKData.shared.USER_ID, profileID: WakatoonSDKData.shared.PROFILE_ID, storyID: WakatoonSDKData.shared.currentStoryID, seasonID: WakatoonSDKData.shared.currentSeasonID, episodeId: WakatoonSDKData.shared.currentEpisodeID)
            }) {
                var oldModel = episodeCacheModelArr[index]
                removeFile(name: oldModel.savedFileName ?? "")
                oldModel.savedFileName = self.savedFileName
                oldModel.loopTimecode = loopTimecode
                if cacheFor == .EPISODE_DATA {
                    oldModel.userName = Common.getPreviousName()
                }
                episodeCacheModelArr[index] = oldModel
                UserDefaults.standard.save(episodeCacheModelArr, forKey: cacheFor.rawValue)
            } else {
                var videoCacheModel = VideoCacheModel(userID: WakatoonSDKData.shared.USER_ID, profileID: WakatoonSDKData.shared.PROFILE_ID, storyID: WakatoonSDKData.shared.currentStoryID, seasonID: WakatoonSDKData.shared.currentSeasonID, episodeId: WakatoonSDKData.shared.currentEpisodeID, savedFileName: savedFileName, loopTimecode: loopTimecode)
                if cacheFor == .EPISODE_DATA {
                    videoCacheModel.userName = Common.getPreviousName()
                }
                episodeCacheModelArr.append(videoCacheModel)
                UserDefaults.standard.save(episodeCacheModelArr, forKey: cacheFor.rawValue)
            }
        } else {
            var videoCacheModel = VideoCacheModel(userID: WakatoonSDKData.shared.USER_ID, profileID: WakatoonSDKData.shared.PROFILE_ID, storyID: WakatoonSDKData.shared.currentStoryID, seasonID: WakatoonSDKData.shared.currentSeasonID, episodeId: WakatoonSDKData.shared.currentEpisodeID, savedFileName: savedFileName, loopTimecode: loopTimecode)
            if cacheFor == .EPISODE_DATA {
                videoCacheModel.userName = Common.getPreviousName()
            }
            UserDefaults.standard.save([videoCacheModel], forKey: cacheFor.rawValue)
        }
    }
    
    func removeCacheVideo(_ cacheFor: CacheFor) {
        if var episodeCacheModelArr: [VideoCacheModel] = UserDefaults.standard.getObject(forKey: cacheFor.rawValue) {
            if let index = episodeCacheModelArr.firstIndex(where: { cacheModel in
                return cacheModel == VideoCacheModel(userID: WakatoonSDKData.shared.USER_ID, profileID: WakatoonSDKData.shared.PROFILE_ID, storyID: WakatoonSDKData.shared.currentStoryID, seasonID: WakatoonSDKData.shared.currentSeasonID, episodeId: WakatoonSDKData.shared.currentEpisodeID)
            }) {
                if let savedfileName = episodeCacheModelArr[index].savedFileName {
                    removeFile(name: savedfileName)
                }
                episodeCacheModelArr.remove(at: index)
                UserDefaults.standard.save(episodeCacheModelArr, forKey: cacheFor.rawValue)
            }
        }
    }
    
    func getEpisodeArtistName(_ cacheFor: CacheFor = .EPISODE_DATA) -> String? {
        if let episodeCacheModelArr: [VideoCacheModel] = UserDefaults.standard.getObject(forKey: cacheFor.rawValue), let cacheModel = episodeCacheModelArr.filter({ model in
            return (model.userID == WakatoonSDKData.shared.USER_ID && model.profileID == WakatoonSDKData.shared.PROFILE_ID && model.storyID == WakatoonSDKData.shared.currentStoryID && model.seasonID == WakatoonSDKData.shared.currentSeasonID && model.episodeId == WakatoonSDKData.shared.currentEpisodeID)
        }).first, let userName = cacheModel.userName {
            return userName
        }
        return nil
    }
    
}

//MARK: - INTRO VIDEO

extension VideoCacheModel {
    
    func isIntroCached() -> (Bool, String?, Double?) {
        if let episodeCacheModelArr: [VideoCacheModel] = UserDefaults.standard.getObject(forKey: "INTRO_CACHE_DATA"), let cacheModel = episodeCacheModelArr.filter({ model in
            return (model.storyID == WakatoonSDKData.shared.currentStoryID && model.seasonID == WakatoonSDKData.shared.currentSeasonID && model.episodeId == WakatoonSDKData.shared.currentEpisodeID)
        }).first, let cacheName = cacheModel.savedFileName, let cacheURLString = self.getFilePath(name: cacheName), let loopTimecode = cacheModel.loopTimecode {
            return (true, cacheURLString, loopTimecode)
        } else {
            return (false, nil, nil)
        }
    }
    
    func saveIntroCacheVideo(loopTimecode: Double?) {
        if var episodeCacheModelArr: [VideoCacheModel] = UserDefaults.standard.getObject(forKey: "INTRO_CACHE_DATA") {
            if let index = episodeCacheModelArr.firstIndex(where: { cacheModel in
                return cacheModel == VideoCacheModel(storyID: WakatoonSDKData.shared.currentStoryID, seasonID: WakatoonSDKData.shared.currentSeasonID, episodeId: WakatoonSDKData.shared.currentEpisodeID)
            }) {
                var oldModel = episodeCacheModelArr[index]
                removeFile(name: oldModel.savedFileName ?? "")
                oldModel.savedFileName = self.savedFileName
                oldModel.loopTimecode = loopTimecode
                episodeCacheModelArr[index] = oldModel
                UserDefaults.standard.save(episodeCacheModelArr, forKey: "INTRO_CACHE_DATA")
            } else {
            episodeCacheModelArr.append(VideoCacheModel(storyID: WakatoonSDKData.shared.currentStoryID, seasonID: WakatoonSDKData.shared.currentSeasonID, episodeId: WakatoonSDKData.shared.currentEpisodeID, savedFileName: savedFileName, loopTimecode: loopTimecode))
                UserDefaults.standard.save(episodeCacheModelArr, forKey: "INTRO_CACHE_DATA")
            }
        } else {
            UserDefaults.standard.save([VideoCacheModel(storyID: WakatoonSDKData.shared.currentStoryID, seasonID: WakatoonSDKData.shared.currentSeasonID, episodeId: WakatoonSDKData.shared.currentEpisodeID, savedFileName: savedFileName, loopTimecode: loopTimecode)], forKey: "INTRO_CACHE_DATA")
        }
    }
    
}

//MARK: - GET LOCAL URL
extension VideoCacheModel {
    
    func removeFile(name: String) {
        guard name.trimmingCharacters(in: .whitespacesAndNewlines).count > 0 else {return}
        let url = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
        let files = FileManager.default.enumerator(atPath: url.relativePath)
        var string: String? = nil
        while let file = files?.nextObject() {
            let tempURL = URL(string: "\(url.absoluteString)/\(file)")
            if tempURL?.lastPathComponent == name {
                string = tempURL?.absoluteString
                break
            }
        }
        guard let str = string, let fileURL = URL(string: str) else {return}
        do {
            try FileManager.default.removeItem(at: fileURL)
            if WakatoonSDKData.shared.isDebugEnable {
                print("File remove with name: \(name)")
            }
        } catch {
            if WakatoonSDKData.shared.isDebugEnable {
                print(error.localizedDescription)
            }
        }
    }
    
    func getFilePath(name: String) -> String? {
        let url = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
        let files = FileManager.default.enumerator(atPath: url.relativePath)
        var string: String? = nil
        while let file = files?.nextObject() {
            let tempURL = URL(string: "\(url.absoluteString)/\(file)")
            if tempURL?.lastPathComponent == name {
                string = tempURL?.absoluteString
                break
            }
        }
        return string
    }
    
}
