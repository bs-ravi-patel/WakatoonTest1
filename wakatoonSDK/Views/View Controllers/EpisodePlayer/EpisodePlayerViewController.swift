//
//  EpisodePlayerViewController.swift
//  wakatoonSDK
//
//  Created by bs-mac-4 on 27/12/22.
//

import UIKit
import AVFoundation

protocol NextPlayEpisodeDelegate {
    func playNextEpisode()
    func backFromEpisode()
}


class EpisodePlayerViewController: BaseViewController {
    
    //MARK: - VARIABLES
    var videoUrlStr = String()
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    var isEpisodeDrwan:Bool = false
    var isStrartPlaying: Bool = false
    var isRetakeImage: Bool = false
    var downloadedVideoURLString: String? = nil
    private let playerPlayingOvserver = "rate"
    var isSetOnlyUserName: Bool = true
    
    //MARK: - OUTLETS
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var playerContainerView: UIView!
    
    
    //MARK: - LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTapGesture()
        backBtn.setBackButtonLayout(viewController: self)
        backBtn.alpha = 0
        setupView()
        if isSetOnlyUserName, let userName = Common.getPreviousName() {
            VideoCacheModel(userName: userName).saveCacheVideo(.EPISODE_DATA, loopTimecode: nil)
        }
    }
    
    override func viewDidLayoutSubviews() {
        DispatchQueue.main.async { [self] in
            playerLayer?.frame = playerContainerView.bounds
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removePlayerNotifations()
        player?.pause()
        player = nil
    }
    
    static func FromStoryBoard() -> Self {
        return  EpisodePlayerViewController(nibName: "EpisodePlayerViewController", bundle: Bundle(for: EpisodePlayerViewController.self)) as! Self
    }
    
    private func setupView() {
        setupPlayer()
        if isSetOnlyUserName {
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now()+5, execute: {
                self.downloadVideo(urlString: self.videoUrlStr)
            })
        }
    }
    
    //MARK: - BTNS ACTIONS
    @IBAction func backBtnAction(_ sender: UIButton) {
        WakatoonSDKData.shared.delegate.videoPlaybackStopped()
        removePlayerNotifations()
        WakatoonSDKData.shared.nextEpisodeDelegate?.backFromEpisode()
    }
    
    //MARK: - SETUP PLAYER
    private func setupPlayer() {
        guard let url = URL(string: videoUrlStr) else {return}
        player = AVPlayer(url: url)
        playerLayer?.removeFromSuperlayer()
        playerLayer = AVPlayerLayer(player: player)
        playerContainerView.layer.addSublayer(playerLayer ?? AVPlayerLayer())
        playerLayer?.frame = playerContainerView.frame
        playerLayer?.frame.origin = .zero
        playerLayer?.videoGravity = .resizeAspect
        player?.addObserver(self, forKeyPath: playerPlayingOvserver, options: [], context: nil)
        player?.play()
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem, queue: .main) { _ in
            self.gotoReplayAndSharePopup()
        }
        player?.addObserver(self, forKeyPath: playerPlayingOvserver, options: [.old, .new], context: nil)
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [self] _ in
            if let player = player, !player.isPlaying, self.navigationController?.topViewController == self {
                player.play()
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == playerPlayingOvserver {
            if (player?.rate ?? 0) > 0 && !isStrartPlaying{
                isStrartPlaying = true
                WakatoonSDKData.shared.delegate.videoPlaybackStarted()
            }
        }
    }
    
    private func removePlayerNotifations() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.removeObserver(self, name:UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    private func setupTapGesture() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapView(_:)))
        self.view.addGestureRecognizer(tapGestureRecognizer)
        self.view.bringSubviewToFront(self.backBtn)
    }
    
    @objc func didTapView(_ sender: UITapGestureRecognizer) {
        if backBtn.alpha == 1 {
            self.backBtn.alpha = 0
        }else {
            self.backBtn.alpha = 1
            DispatchQueue.main.asyncAfter(deadline: .now()+3, execute: {
                UIView.animate(withDuration: 1) {
                    self.backBtn.alpha = 0
                }
            })
        }
    }
    
    //MARK: - GOTO REPLAY AND SHARE POPUP -
    private func gotoReplayAndSharePopup() {
        let replayAndShareVC = ReplayAndShareViewController.FromStoryBoard()
        replayAndShareVC.replayCallback = {
            let result = VideoCacheModel().isVideoCached(.EPISODE_DATA)
            if result.0, let url = result.1 {
                self.videoUrlStr = url
                self.setupPlayer()
            } else {
                self.player?.seek(to: CMTime.zero)
                self.player?.play()
            }
        }
        replayAndShareVC.nextEpisodeCallback = {
            self.removePlayerNotifations()
            WakatoonSDKData.shared.delegate.videoPlaybackStopped()
            WakatoonSDKData.shared.nextEpisodeDelegate?.playNextEpisode()
        }
        replayAndShareVC.closeCallback = {
            WakatoonSDKData.shared.delegate.videoPlaybackStopped()
            self.navigationController?.popToViewController(ofClass: VideoPlayerViewController.self)
        }
        replayAndShareVC.modalPresentationStyle = .overFullScreen
        replayAndShareVC.modalTransitionStyle = .crossDissolve
        present(replayAndShareVC, animated: true)
    }
    
    private func downloadVideo(urlString: String) {
        guard let url = URL(string: videoUrlStr) else {return}
        DownloadManager(name: UUID().uuidString, url: url).download { percent in
            if WakatoonSDKData.shared.isDebugEnable {
                print("download percent",percent)
            }
        }.finish { (relativePath) in
            let savedVideoString = WakatoonSDKData.shared.homeDirectoryURL.absoluteString + relativePath
            VideoCacheModel(savedURLString: savedVideoString).saveCacheVideo(.EPISODE_DATA, loopTimecode: nil)
        }.onError { (error) in
            DispatchQueue.main.asyncAfter(deadline: .now()+5, execute: {
                if self.navigationController?.topViewController == self {
                    self.downloadVideo(urlString: urlString)
                }
            })
        }
    }
    
}
