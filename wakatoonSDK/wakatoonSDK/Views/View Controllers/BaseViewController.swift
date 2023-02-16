//
//  BaseViewController.swift
//  wakatoonSDK
//
//  Created by bs-mac-4 on 11/01/23.
//

import UIKit

class BaseViewController: UIViewController {

    //MARK: - VARIABLES
    
    //MARK: - OUTLETS
    
    //MARK: - LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setDeviceOrientation(orientation: .landscapeRight)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeRight
    }
    
    @objc func canRotate() -> Void {}
    
}
