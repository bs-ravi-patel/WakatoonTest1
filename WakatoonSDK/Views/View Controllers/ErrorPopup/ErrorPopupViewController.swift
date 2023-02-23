//
//  ErrorPopupViewController.swift
//  wakatoonSDK
//
//  Created by bs-mac-4 on 20/12/22.
//

import UIKit

class ErrorPopupViewController: BaseViewController {

    //MARK: - VARIABLES
    
    var errorModal: ErrorModel?
    var isRetryShow: Bool = false
    var isCancleyShow: Bool = true
    var retryCallBack: (()->())?
    
    //MARK: - OUTLETS
    @IBOutlet weak var errorTitleLbl: UILabel!
    @IBOutlet weak var errorMessageLbl: UILabel!
    @IBOutlet weak var cancleBtn: UIButton!
    @IBOutlet weak var retryBtn: UIButton!
    
    //MARK: - LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    static func FromStoryBoard() -> Self {
        return  ErrorPopupViewController(nibName: "ErrorPopupViewController", bundle: Bundle(for: ErrorPopupViewController.self)) as! Self
    }
    
    private func setupView() {
        guard let errorModal = errorModal else {return}
        errorTitleLbl.text = errorModal.errorType ?? ""
        errorMessageLbl.text = errorModal.errorMessage ?? ""
        errorTitleLbl.font = getFont(size: 17, style: .SemiBold)
        errorMessageLbl.font = getFont(size: 15, style: .Medium)
        retryBtn.isHidden = !isRetryShow
        cancleBtn.isHidden = !isCancleyShow
        cancleBtn.setTitle("\(isRetryShow ? "cancle" : "ok")".localized, for: .normal)
        retryBtn.setTitle("retry".localized, for: .normal)
    }
    
    //MARK: - BTNS ACTIONS
    @IBAction func cancleBtn(_ sender: UIButton) {
        dismiss(animated: true)
    }
    @IBAction func retryBtn(_ sender: UIButton) {
        if let retryCallBack = self.retryCallBack {
            dismiss(animated: true) {
                retryCallBack()
            }
        }
    }
    
}
