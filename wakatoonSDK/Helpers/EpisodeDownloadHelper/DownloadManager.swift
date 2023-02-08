//
//  DownloadManager.swift
//  wakatoonSDK
//
//  Created by bs-mac-4 on 16/01/23.
//

import Foundation
import AVFoundation


public typealias downloadProgress = (Double) -> Void
public typealias downloadFinish = (String) -> Void
public typealias downloadError = (Error) -> Void

class DownloadManager: NSObject {
    
    //MARK: - VARIABLES
    private var name: String = ""
    private var urlAsset: AVURLAsset
    private var session: AVAssetDownloadURLSession!
    
    enum Result {
        case success
        case failure(Error)
    }
    internal var result: Result?
    internal var progressClosure: downloadProgress?
    internal var finishClosure: downloadFinish?
    internal var errorClosure: downloadError?
    
    //MARK: - INIT
    
    public init(name: String, url: URL) {
        self.name = name
        let urlAsset = AVURLAsset(url: url, options: nil)
        self.urlAsset = urlAsset
        self.session = nil
    }
    
    
    //MARK: - DOWNLOAD
    func downloadVideo() {
        let configuration = URLSessionConfiguration.background(withIdentifier: "\(UUID().uuidString).configuration")
        session = AVAssetDownloadURLSession(configuration: configuration,
                                            assetDownloadDelegate: self,
                                            delegateQueue: OperationQueue.main)
        guard let task = session.makeAssetDownloadTask(asset: self.urlAsset, assetTitle: self.name, assetArtworkData: nil, options: [AVAssetDownloadTaskMinimumRequiredMediaBitrateKey: 265_000]) else { return }
        
        task.taskDescription = self.name
        task.resume()
    }
    
    @discardableResult
    public func download(progress closure: downloadProgress? = nil) -> Self {
        progressClosure = closure
        self.downloadVideo()
        return self
    }
    
    /// Set progress closure.
    ///
    /// - Parameter closure: Progress closure that will invoke when download each time range files.
    /// - Returns: Chainable self instance.
    @discardableResult
    public func progress(progress closure: @escaping downloadProgress) -> Self {
        progressClosure = closure
        return self
    }
    
    /// Set finish(success) closure.
    ///
    /// - Parameter closure: Finish closure that will invoke when successfully finished download media.
    /// - Returns: Chainable self instance.
    @discardableResult
    public func finish(relativePath closure: @escaping downloadFinish) -> Self {
        finishClosure = closure
        if let result = result, case .success = result {
            closure(AssetStore.path(forName: name)!)
        }
        return self
    }
    
    /// Set failure closure.
    ///
    /// - Parameter closure: Finish closure that will invoke when failure finished download media.
    /// - Returns: Chainable self instance.
    @discardableResult
    public func onError(error closure: @escaping downloadError) -> Self {
        errorClosure = closure
        if let result = result, case .failure(let err) = result {
            closure(err)
        }
        return self
    }
    
}

// MARK: - AVAssetDownloadDelegate

extension DownloadManager: AVAssetDownloadDelegate {
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error as NSError? {
            switch (error.domain, error.code) {
                case (NSURLErrorDomain, NSURLErrorCancelled):
                    guard let localFileLocation = AssetStore.path(forName: self.name) else { return }
                    do {
                        let fileURL = WakatoonSDKData.shared.homeDirectoryURL.appendingPathComponent(localFileLocation)
                        try FileManager.default.removeItem(at: fileURL)
                    } catch {
                        if WakatoonSDKData.shared.isDebugEnable {
                            print("An error occured trying to delete the contents on disk for \(self.name): \(error)")
                        }
                    }
                case (NSURLErrorDomain, NSURLErrorUnknown):
                    self.result = .failure(error)
                    if WakatoonSDKData.shared.isDebugEnable {
                        print("Downloading HLS streams is not supported in the simulator.",error.localizedDescription)
                    }
                default:
                    self.result = .failure(error)
            }
        } else {
            self.result = .success
        }
        if let result = self.result {
            switch result {
                case .success:
                    self.finishClosure?(AssetStore.path(forName: self.name)!)
                case .failure(let error):
                    self.errorClosure?(error)
            }
        }
    }
    
    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didFinishDownloadingTo location: URL) {
        AssetStore.set(path: location.relativePath, forName: self.name)
    }
    
    func urlSession(_ session: URLSession,
                    assetDownloadTask: AVAssetDownloadTask,
                    didLoad timeRange: CMTimeRange,
                    totalTimeRangesLoaded loadedTimeRanges: [NSValue],
                    timeRangeExpectedToLoad: CMTimeRange) {
        let percentComplete = loadedTimeRanges.reduce(0.0) {
            let loadedTimeRange : CMTimeRange = $1.timeRangeValue
            return $0 + CMTimeGetSeconds(loadedTimeRange.duration) / CMTimeGetSeconds(timeRangeExpectedToLoad.duration)
        }
        self.progressClosure?(percentComplete)
    }
    
}
extension Error {
    var errorCode:Int? {
        return (self as NSError).code
    }
}
