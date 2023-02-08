//
//  ExtractionOKViewController.swift
//  wakatoonSDK
//
//  Created by bs-mac-4 on 21/12/22.
//

import UIKit

class ExtractionOKViewController: BaseViewController {

    //MARK: - VARIABLES
    var extractedImageModel:ExtractImageModal?
    var isFromEpisodeDrwan:Bool = false
    
    //MARK: - OUTLETS
    @IBOutlet weak var extractionHappyLbl: UILabel!
    @IBOutlet weak var extractedImage: UIImageView!
    @IBOutlet weak var noBtn: UIButton!
    @IBOutlet weak var yesBtn: UIButton!
    
    //MARK: - LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    static func FromStoryBoard() -> Self {
        return  ExtractionOKViewController(nibName: "ExtractionOKViewController", bundle: Bundle(for: ExtractionOKViewController.self)) as! Self
    }
    
    private func setupView() {
        showLoader()
        DispatchQueue.global().async {
            guard let urlString = self.extractedImageModel?.extractedArtworkImageUrl, let url = URL(string: urlString) else {return}
            if let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    self.hideLoader()
                    self.extractedImage.image = UIImage(data: data)
                }
            }
        }
        extractionHappyLbl.text = "happy_with_your_drawing".localized
        extractionHappyLbl.font = getFont(size: 17, style: .SemiBold)
        noBtn.setTitle("no_capital".localized, for: .normal)
        yesBtn.setTitle("yes_capital".localized, for: .normal)
        noBtn.titleLabel?.font = getFont(size: 15, style: .Medium)
        yesBtn.titleLabel?.font = getFont(size: 15, style: .Medium)
    }
    
    //MARK: - BTNS ACTIONS
    @IBAction func yesNoBtnsAction(_ sender: UIButton) {
        guard let photoID = extractedImageModel?.photoId else {return}
        showLoader()
        APIManager.shared.validateExtractImage(photoID: photoID, status: sender.tag == 0 ? .No : .Yes) { response, error in
            if let response = response {
                DispatchQueue.main.async {
                    if sender.tag == 0 {
                        self.hideLoader()
                        NotificationCenter.default.post(name: NSNotification.Name("PLAY_CAMERA_DEFUALT_SOUND"), object: nil)
                        self.navigationController?.popToViewController(ofClass: CameraViewController.self)
                    }else {
                        VideoCacheModel().removeCacheVideo(.DETECTED_LOOP_DATA)
                        VideoCacheModel().removeCacheVideo(.DETECTED_DATA)
                        EpisodeDrawnModel().setEpisodeDrawn(true)
                        var extractionValidateModal: ExtractImageValidateModal?
                        extractionValidateModal = Common.decodeDataToObject(data: response)
                        if let _ = extractionValidateModal?.photoId {
                            self.hideLoader()
                            let loadingVC = LoadingViewController.FromStoryBoard()
                            loadingVC.loadingTitle = "preparing_your_cartoon".localized
                            loadingVC.isForPrepareCartoonOverview = true
                            loadingVC.overviewVideoCreate = { url, loopTime in
                                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "NEW_IMAGE_SELECT")))
                                loadingVC.popViewController(animated: false)
                                let videoOverViewVC = VideoOverviewViewController.FromStoryBoard()
                                videoOverViewVC.videoModal = VideoGenModal(videoUrl: url, startLoopingAt: StartLoopingAt(seconds: loopTime))
                                self.pushViewController(view: videoOverViewVC)
                                Common.downloadEpisodeFromURL(url, isFor: .DETECTED, loopTimecode: loopTime)
                            }
                            self.pushViewController(view: loadingVC)
                        }
                    }
                }
            }else {
                if let error = error as? NSError {
                    let userInfo = error.userInfo
                    DispatchQueue.main.async {
                        self.hideLoader()
                        self.showErrorPopUP(errorModel: userInfo["error"] as? ErrorModel,isCancleShow: false, isRetryShow: true, retry: {
                            self.popViewController()
                        })
                    }
                }
            }
        }
    }
    
}
