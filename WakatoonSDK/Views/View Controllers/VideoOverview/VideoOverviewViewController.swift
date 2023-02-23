//
//  VideoOverviewViewController.swift
//  wakatoonSDK
//
//  Created by bs-mac-4 on 22/12/22.
//

import UIKit
import MediaPlayer


class VideoOverviewViewController: BaseViewController {
    
    //MARK: - VARIABLES
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    var isEpisodeDrwan:Bool = false
    var isRetakeImage: Bool = false
    var videoModal: VideoGenModal?
    
    //MARK: - OUTLETS
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var playerContainerView: UIView!
    @IBOutlet weak var retakeBtn: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    
    //MARK: - LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupPlayer()
        backBtn.setBackButtonLayout(viewController: self)
        let playImage = UIImage(named: "play", in: Bundle(for: type(of: self)), compatibleWith: nil)?.imageWithColor(color: .white)
        playBtn.setImage(playImage, for: .normal)
        playBtn.setImage(playImage, for: .highlighted)
        let cam_retake = UIImage(named: "camera_retake", in: Bundle(for: type(of: self)), compatibleWith: nil)?.imageWithColor(color: .systemTeal)
        retakeBtn.setImage(cam_retake, for: .normal)
        retakeBtn.setImage(cam_retake, for: .highlighted)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let player = player, !player.isPlaying {
            player.play()
        } else if player == nil {
            let result = VideoCacheModel().isVideoCached(.DETECTED_DATA)
            if result.0, let url = result.1, let loopTime = result.2 {
                self.videoModal = VideoGenModal(videoUrl: url, startLoopingAt: StartLoopingAt(seconds: loopTime))
            }
            setupPlayer()
        }
    }
    
    override func viewDidLayoutSubviews() {
        DispatchQueue.main.async { [self] in
            playerLayer?.frame = playerContainerView.bounds
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        player?.pause()
        player = nil
    }
    
    static func FromStoryBoard() -> Self {
        return  VideoOverviewViewController(nibName: "VideoOverviewViewController", bundle: Bundle(for: VideoOverviewViewController.self)) as! Self
    }
    
    //MARK: - BTNS ACTIONS
    
    @IBAction func backBtnAction(_ sender: UIButton) {
        removePlayerNotifations()
        self.navigationController?.popToViewControllerWithGivenClass(ofClass: VideoPlayerViewController.self)
    }
    
    @IBAction func retakeImageAction(_ sender: UIButton) {
        removePlayerNotifations()
        NotificationCenter.default.post(name: NSNotification.Name("PLAY_CAMERA_DEFUALT_SOUND"), object: nil)
        self.navigationController?.popToViewController(ofClass: CameraViewController.self)
    }
    
    @IBAction func playAction(_ sender: UIButton) {
        removePlayerNotifations()
        gotoEnterNameViewController()
    }
    
    //MARK: - SETUP PLAYER
    private func setupPlayer() {
        guard let videoUrlStr = videoModal?.videoUrl, let url = URL(string: videoUrlStr) else {return}
        player = AVPlayer(url: url)
        playerLayer?.removeFromSuperlayer()
        playerLayer = AVPlayerLayer(player: player)
        playerContainerView.layer.addSublayer(playerLayer ?? AVPlayerLayer())
        playerLayer?.frame = playerContainerView.frame
        playerLayer?.frame.origin = .zero
        playerLayer?.videoGravity = .resizeAspect
        playerContainerView.layoutIfNeeded()
        playerLayer?.layoutIfNeeded()
        
        player?.play()
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem, queue: .main) { [weak self] _ in
            DispatchQueue.main.async {
                if let loopTime = self?.videoModal?.loopTimecodeSecond() {
                    self?.player?.seek(to: CMTime(seconds: Double(loopTime), preferredTimescale: 6000))
                } else {
                    self?.player?.seek(to: CMTime(seconds: Double(0), preferredTimescale: 6000))
                }
                self?.player?.play()
            }
        }
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [weak self] _ in
            if self?.navigationController?.topViewController == self {
                DispatchQueue.main.async {
                    if let loopTime = self?.videoModal?.loopTimecodeSecond() {
                        self?.player?.seek(to: CMTime(seconds: Double(loopTime), preferredTimescale: 6000))
                    } else {
                        self?.player?.seek(to: CMTime(seconds: Double(0), preferredTimescale: 6000))
                    }
                    self?.player?.play()
                }
            }
        }
    }
    
    private func removePlayerNotifations() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.removeObserver(self, name:UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    private func gotoEnterNameViewController() {
        let enterNameVC = EnterNameViewController.FromStoryBoard()
        enterNameVC.name = { name in
            let loadingVC = LoadingViewController.FromStoryBoard()
            loadingVC.isForPrepareEpisode = true
            loadingVC.name = name
            loadingVC.loadingTitle = "preparing_your_cartoon".localized
            loadingVC.overviewVideoCreate = { url, loopTime in
                loadingVC.popViewController(animated: false)
                let episodePlayerVC = EpisodePlayerViewController.FromStoryBoard()
                episodePlayerVC.isEpisodeDrwan = self.isEpisodeDrwan
                episodePlayerVC.isRetakeImage = self.isRetakeImage
                episodePlayerVC.videoUrlStr = url
                self.pushViewController(view: episodePlayerVC)
            }
            self.pushViewController(view: loadingVC)
        }
        enterNameVC.modalPresentationStyle = .overFullScreen
        enterNameVC.modalTransitionStyle = .crossDissolve
        present(enterNameVC, animated: true)
    }
    
}

