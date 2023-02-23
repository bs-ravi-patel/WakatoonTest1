//
//  CameraViewController.swift
//  wakatoonSDK
//
//  Created by bs-mac-4 on 19/12/22.
//

import UIKit
import AVFoundation

class CameraViewController: BaseViewController {
    
    //MARK: - VARIABLES
    var overlay: ArtworkModel?
    var captureSession : AVCaptureSession!
    var backCamera : AVCaptureDevice!
    var backInput : AVCaptureInput!
    var previewLayer : AVCaptureVideoPreviewLayer!
    var stillImageOutput = AVCapturePhotoOutput()
    var isFromEpisodeDrwan:Bool = false
    private var player: AVPlayer?

    
    enum isSoundPlayFor {
        case NOT_ERROR
        case ERROR
    }

    //MARK: - OUTLETS
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var captureBtn: UIButton!
    @IBOutlet weak var overlayIma: UIImageView!
    @IBOutlet weak var cameraContainerView: UIView!
    
    //MARK: - LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        getOverlayImage()
        let backImage = UIImage(named: "close", in: Bundle(for: type(of: self)), compatibleWith: nil)?.imageWithColor(color: .systemTeal)
        closeBtn.setImage(backImage, for: .normal)
        closeBtn.setImage(backImage, for: .highlighted)
        playSound()
        NotificationCenter.default.addObserver(forName: NSNotification.Name("PLAY_CAMERA_DEFUALT_SOUND"), object: nil, queue: .main) { _ in
            self.playSound()
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name("STOP_CAMERA_DEFUALT_SOUND"), object: nil, queue: .main) { _ in
            self.stopPlayer()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupAndStartCaptureSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        captureSession.stopRunning()
        stopPlayer()
    }
    
    static func FromStoryBoard() -> Self {
        return  CameraViewController(nibName: "CameraViewController", bundle: Bundle(for: CameraViewController.self)) as! Self
    }
    
    
    //MARK: - BTNS ACTIONS
    @IBAction func closeBtnAction(_ sender: UIButton) {
        stopPlayer()
        self.navigationController?.popToViewController(ofClass: VideoPlayerViewController.self)
    }
    
    @IBAction func captureBtnAction(_ sender: UIButton) {
        DispatchQueue.main.async { [self] in
            stopPlayer()
        }
        #if targetEnvironment(simulator)
            if let image = UIImage(named: "SampleArtwork_WAM0001_S1_E1", in: Bundle(for: type(of: self)), compatibleWith: nil) {
                Common.saveImageInTemporaryDirectory(image: image, withName: "test.jpg") { url in
                    if let url = url {
                        let loadingVC = LoadingViewController.FromStoryBoard()
                        loadingVC.loadingTitle = "detecting_your_drawing".localized
                        loadingVC.captureImage = url
                        loadingVC.originalImage = image
                        self.pushViewController(view: loadingVC)
                    }
                }
            }
        #else
            let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
            stillImageOutput.capturePhoto(with: settings, delegate: self)
        #endif
    }
}


//MARK: - CAMERA FUNCTIONS -
extension CameraViewController : AVCapturePhotoCaptureDelegate {
    
    private func setupAndStartCaptureSession(){
        DispatchQueue.global(qos: .userInitiated).async{
            self.captureSession = AVCaptureSession()
            self.captureSession.beginConfiguration()
            if self.captureSession.canSetSessionPreset(.photo) {
                self.captureSession.sessionPreset = .iFrame1280x720
            }
            self.captureSession.automaticallyConfiguresCaptureDeviceForWideColor = true
            self.setupInputs()
            DispatchQueue.main.async {
                self.setupPreviewLayer()
            }
            self.captureSession.commitConfiguration()
            self.captureSession.startRunning()
        }
    }
    
    private func setupInputs(){
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            backCamera = device
        } else {
            return
        }
        guard let bInput = try? AVCaptureDeviceInput(device: backCamera) else {
            if WakatoonSDKData.shared.isDebugEnable {
                fatalError("could not create input device from back camera")
            }
            return
        }
        backInput = bInput
        if !captureSession.canAddInput(backInput) {
            if WakatoonSDKData.shared.isDebugEnable {
                fatalError("could not add back camera input to capture session")
            }
        }
        
        captureSession.addInput(backInput)
        
        stillImageOutput = AVCapturePhotoOutput()
        if captureSession.canAddOutput(stillImageOutput) {
            captureSession.addOutput(stillImageOutput)
        }
    }
    
    private func setupPreviewLayer(){
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer!.videoGravity = .resizeAspect
        previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.landscapeRight
        cameraContainerView.layer.addSublayer(previewLayer)
        previewLayer.frame = self.cameraContainerView.bounds
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData), let newImage = image.resizedImageWithinRect(rectSize: CGSize(width: self.overlayIma.frame.size.width, height: self.overlayIma.frame.size.height))
        else { return }
        let finalImage = newImage.rotate().rotate().rotate()
        Common.saveImageInTemporaryDirectory(image: finalImage, withName: UUID().uuidString+".jpg") { url in
            if let url = url {
                let loadingVC = LoadingViewController.FromStoryBoard()
                loadingVC.loadingTitle = "detecting_your_drawing".localized
                loadingVC.captureImage = url
                loadingVC.originalImage = image
                loadingVC.extractImageGet = { response in
                    if response == nil {
                        self.playSound(isPlayFor: CameraViewController.isSoundPlayFor.ERROR)
                    }
                }
                self.pushViewController(view: loadingVC)
            }
        }
    }
    
}

extension CameraViewController {

    func playSound(isPlayFor: isSoundPlayFor =  CameraViewController.isSoundPlayFor.NOT_ERROR) {
        stopPlayer()
        player = nil
        var fileName: String? = nil
        switch WakatoonSDKData.shared.selectedLanguage {
            case .en:
                fileName = nil
            case .fr:
                fileName = isPlayFor == .NOT_ERROR ? "fr_aim_at_your_drawing" : "fr_drawing_not_detected"
        }
        if fileName == nil {
            return
        }
        DispatchQueue.main.async {[weak self] in
            if let bundle = Bundle(identifier: WakatoonSDKData.shared.BundelID), let url = bundle.url(forResource: fileName!, withExtension: "wav") {
                self?.player = AVPlayer(url: url)
                self?.player?.play()
            }
        }
    }
    
    func stopPlayer() {
        player?.pause()
        player = nil
        player = AVPlayer()
        player?.replaceCurrentItem(with: nil)
        player = nil
    }
    
}

//MARK: - API CALLING -

extension CameraViewController {
    
    private func getOverlayImage() {
        showLoader()
        DispatchQueue.global(qos: .background).async {
            APIManager.shared.getOverlayImage { response, error in
                if let response = response {
                    self.overlay = Common.decodeDataToObject(data: response)
                    if let overlayIma = self.overlay?.imageUrl, let url = URL(string: overlayIma) {
                        DispatchQueue.global().async {
                            if let data = try? Data(contentsOf: url) {
                                DispatchQueue.main.async {
                                    self.hideLoader()
                                    self.overlayIma.image = UIImage(data: data)
                                }
                            }
                        }
                    }
                }else {
                    if let error = error as? NSError {
                        let userInfo = error.userInfo
                        DispatchQueue.main.async {
                            self.hideLoader()
                            self.showErrorPopUP(errorModel: userInfo["error"] as? ErrorModel, retry: {})
                        }
                    }
                }
            }
        }
    }
    
}

extension UIImageView {
    var contentClippingRect: CGRect {
        guard let image = image else { return bounds }
        guard contentMode == .scaleAspectFit else { return bounds }
        guard image.size.width > 0 && image.size.height > 0 else { return bounds }

        let scale: CGFloat
        if image.size.width > image.size.height {
            scale = bounds.width / image.size.width
        } else {
            scale = bounds.height / image.size.height
        }

        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let x = (bounds.width - size.width) / 2.0
        let y = (bounds.height - size.height) / 2.0

        return CGRect(x: x, y: y, width: size.width, height: size.height)
    }
}
