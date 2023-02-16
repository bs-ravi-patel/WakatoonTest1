//
//  LoadingViewController.swift
//  wakatoonSDK
//
//  Created by bs-mac-4 on 20/12/22.
//

import UIKit

class LoadingViewController: BaseViewController {
    
    //MARK: - VARIABLES
    var captureImage: URL? {
        didSet {
            DispatchQueue.global(qos: .background).async {
                self.extractImageAPICall()
            }
        }
    }
    var originalImage: UIImage?
    var loadingTitle = String()
    var extractedImageModel:ExtractImageModal?
    var extractImageGet: ((_ extractedImageModel: ExtractImageModal?)->())?
    
    var isForPrepareCartoonOverview: Bool = false
    var videoModal: VideoGenModal?
    var overviewVideoCreate: ((_ videoModal: String, _ loopTimecode: Double?)->())?
    
    var isForPrepareEpisode: Bool = false
    var name = String()
    
    //MARK: - OUTLETS
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var percentLbl: UILabel!
    
    //MARK: - LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.post(name: NSNotification.Name("STOP_CAMERA_DEFUALT_SOUND"), object: nil)
        setupView()
    }
    
    static func FromStoryBoard() -> Self {
        return  LoadingViewController(nibName: "LoadingViewController", bundle: Bundle(for: LoadingViewController.self)) as! Self
    }
    
    private func setupView() {
        titleLbl.text = loadingTitle
        titleLbl.font = getFont(size: 17, style: .Medium)
        percentLbl.font = getFont(size: 13, style: .Medium)
        percentLbl.isHidden = true
        if isForPrepareCartoonOverview {
            percentLbl.isHidden = false
            percentLbl.text = "0 %"
            createVideo(lable: .DETECTED)
        }
        if isForPrepareEpisode {
            percentLbl.isHidden = false
            percentLbl.text = "0 %"
            createVideo(lable: .EPISODE, name: name)
        }
    }
    
    
}

//MARK: - API CALLING -
extension LoadingViewController {
    
    private func extractImageAPICall() {
        guard let captureImage = captureImage else {return}
        APIManager.shared.getExtractedImage(image: captureImage, originalImage: self.originalImage) { response, error in
            DispatchQueue.main.async {
                if let response = response {
                    self.extractedImageModel = Common.decodeDataToObject(data: response)
                    if let isSuccess = self.extractedImageModel?.extractionSucceeded, isSuccess {
                        let extractionOKVC = ExtractionOKViewController.FromStoryBoard()
                        extractionOKVC.extractedImageModel = self.extractedImageModel
                        self.pushViewController(view: extractionOKVC, animated: true)
                    } else {
                        if let extractImageGet = self.extractImageGet {
                            extractImageGet(nil)
                        }
                        self.popViewController()
                    }
                } else {
                    if let extractImageGet = self.extractImageGet {
                        extractImageGet(nil)
                    }
                    self.popViewController()
                }
            }
        }
    }
    
    private func createVideo(lable: APIManager.VideoLabel, name: String? = nil) {
        APIManager.shared.getVideo(label: lable, name: name) { response, error in
            if let response = response {
                self.videoModal = Common.decodeDataToObject(data: response)
                if let url = self.videoModal?.videoUrl, let genPercent = self.videoModal?.videoPlayabilityProgress {
                    DispatchQueue.main.async { [self] in
                        let value = Int(round(genPercent * 100))
                        percentLbl.text = "\(value) %"
                        if value == 100 {
                            DispatchQueue.main.asyncAfter(deadline: .now()+1.5, execute: {
                                self.overviewVideoCreate?(url, self.videoModal?.loopTimecodeSecond())
                            })
                        }else {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                self.createVideo(lable: lable, name: name)
                            }
                        }
                    }
                }
            } else {
                if let error = error as? NSError {
                    let userInfo = error.userInfo
                    DispatchQueue.main.async {
                        self.showErrorPopUP(errorModel: userInfo["error"] as? ErrorModel,isCancleShow: false, isRetryShow: true, retry: {
                            self.popViewController()
                        })
                    }
                }
            }
        }
    }
    
}
