//
//  EpisodeDrawnModel.swift
//  wakatoonSDK
//
//  Created by bs-mac-4 on 20/01/23.
//

import Foundation


struct EpisodeDrawnModel: Codable {
    
    var userID: String?
    var profileID: String?
    var storyID: String?
    var seasonID: Int?
    var episodeId: Int?
    
    init() {
        
    }
    
    init(userID: String?, profileID: String?, storyID: String?, seasonID: Int?, episodeId: Int?) {
        self.userID = userID
        self.profileID = profileID
        self.storyID = storyID
        self.seasonID = seasonID
        self.episodeId = episodeId
    }
    
    static func == (lhs: EpisodeDrawnModel, rhs: EpisodeDrawnModel) -> Bool {
        return (lhs.userID == rhs.userID && lhs.profileID == rhs.profileID && lhs.storyID == rhs.storyID && lhs.seasonID == rhs.seasonID && lhs.episodeId == rhs.episodeId)
    }
    
    private func getCurrentEpisodeDetails() -> EpisodeDrawnModel {
        return EpisodeDrawnModel(userID: WakatoonSDKData.shared.USER_ID, profileID: WakatoonSDKData.shared.PROFILE_ID, storyID: WakatoonSDKData.shared.currentStoryID, seasonID: WakatoonSDKData.shared.currentSeasonID, episodeId: WakatoonSDKData.shared.currentEpisodeID)
    }
    
    func isEpisodeDrawn() -> Bool {
        if let episodeDrawnArr: [EpisodeDrawnModel] = UserDefaults.standard.getObject(forKey: "EPISODE_DRAWN"), let _ = episodeDrawnArr.filter({ model in
            return model == self.getCurrentEpisodeDetails()
        }).first {
            return true
        } else {
            return false
        }
    }
    
    func setEpisodeDrawn(_ isDrawn: Bool) {
        if var episodeDrawnArr: [EpisodeDrawnModel] = UserDefaults.standard.getObject(forKey: "EPISODE_DRAWN") {
            if let index = episodeDrawnArr.firstIndex(where: { model in
                return model == self.getCurrentEpisodeDetails()
            }) {
                if !isDrawn {
                    episodeDrawnArr.remove(at: index)
                    UserDefaults.standard.save([self.getCurrentEpisodeDetails()], forKey: "EPISODE_DRAWN")
                }
            } else {
                episodeDrawnArr.append(self.getCurrentEpisodeDetails())
                UserDefaults.standard.save(episodeDrawnArr, forKey: "EPISODE_DRAWN")
            }
        } else {
            UserDefaults.standard.save([self.getCurrentEpisodeDetails()], forKey: "EPISODE_DRAWN")
        }
    }
    
}
