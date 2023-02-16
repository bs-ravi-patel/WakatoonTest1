//
//  CameraPermissionViewController.swift
//  wakatoonSDK
//
//  Created by bs-mac-4 on 19/12/22.
//

import UIKit

class CameraPermissionViewController: BaseViewController {

    //MARK: - VARIABLES
    
    //MARK: - OUTLETS
    @IBOutlet weak var cancleBtn: UIButton!
    @IBOutlet weak var acceptBtn: UIButton!
    @IBOutlet weak var descLbl: UILabel!
    
    
    //MARK: - LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupView()
    }
    
    static func FromStoryBoard() -> Self {
        return  CameraPermissionViewController(nibName: "CameraPermissionViewController", bundle: Bundle(for: CameraPermissionViewController.self))as! Self
    }
    
    private func setupView() {
        cancleBtn.setTitle("reject".localized, for: .normal)
        acceptBtn.setTitle("allow_access_to_the_camera".localized, for: .normal)
        descLbl.text = "description_of_camera_permission".localized
        descLbl.font = getFont(size: 18, style: .Medium)
        acceptBtn.titleLabel?.font = getFont(size: 18, style: .SemiBold)
        cancleBtn.titleLabel?.font = getFont(size: 15, style: .Regular)
    }
    
    //MARK: - BTNS ACTIONS
    @IBAction func cancleBtnAction(_ sender: UIButton) {
        popViewController()
    }
    
    @IBAction func acceptBtnAction(_ sender: UIButton) {
        Common.getCameraPermission { isGranted in
            DispatchQueue.main.async {
                if isGranted {
                    self.pushViewController(view: CameraViewController.FromStoryBoard())
                }else {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                }
            }
        }
    }
    
    
}
