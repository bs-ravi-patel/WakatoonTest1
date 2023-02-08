//
//  LoaderViewController.swift
//  wakatoonSDK
//
//  Created by bs-mac-4 on 22/12/22.
//

import UIKit

class LoaderViewController: BaseViewController {

    //MARK: - VARIABLES
    
    //MARK: - OUTLETS
    
    //MARK: - LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    static func FromStoryBoard() -> Self {
        return  LoaderViewController(nibName: "LoaderViewController", bundle: Bundle(for: LoaderViewController.self)) as! Self
    }
    
    //MARK: - BTNS ACTIONS

}
