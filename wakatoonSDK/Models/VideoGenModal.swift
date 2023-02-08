//
//  VideoGenModal.swift
//  wakatoonSDK
//
//  Created by bs-mac-4 on 22/12/22.
//

import Foundation


struct VideoGenModal: Codable {
    let videoUrl: String?
    let videoPlayabilityProgress: Double?
    let videoGenerationProgress: Double?
    let videoId: String?
    let loopTimecode: String?
    let startLoopingAt: StartLoopingAt?
    
    init(videoUrl: String?, videoPlayabilityProgress: Double? = nil, videoGenerationProgress: Double? = nil, videoId: String? = nil, loopTimecode: String? = nil, startLoopingAt: StartLoopingAt?) {
        self.videoUrl = videoUrl
        self.videoPlayabilityProgress = videoPlayabilityProgress
        self.videoGenerationProgress = videoGenerationProgress
        self.videoId = videoId
        self.loopTimecode = loopTimecode
        self.startLoopingAt = startLoopingAt
    }
    
    public func loopTimecodeSecond() -> Double? {
        if let startLoopingAt = self.startLoopingAt {
            if let seconds = startLoopingAt.seconds {
                return seconds
            } else if let fractional = startLoopingAt.fractional, let value = fractional.value {
                let df = DateFormatter()
                df.dateFormat = "HH:MM:SS.sss"
                if let date = df.date(from: value) {
                    return Double(Calendar.current.component(.second, from: date))
                }
            }
        }
        return nil
    }
    
    
}

struct StartLoopingAt: Codable {
    let smpte: Smpte?
    let fractional: Fractional?
    let seconds: Double?
    let milliseconds: Double?
    
    init(smpte: Smpte? = nil, fractional: Fractional? = nil, seconds: Double? = nil, milliseconds: Double? = nil) {
        self.smpte = smpte
        self.fractional = fractional
        self.seconds = seconds
        self.milliseconds = milliseconds
    }
    
}

struct Smpte: Codable {
    let value: String?
    let format: String? //"HH:MM:SS:FF (Hours:Minutes:Seconds:Frames)"
}

struct Fractional: Codable {
    let value: String?
    let format: String? //"HH:MM:SS.sss (Hours:Minutes:Seconds.Milliseconds)"
}
