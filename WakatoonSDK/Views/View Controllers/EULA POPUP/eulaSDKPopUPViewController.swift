//
//  eulaSDKPopUPViewController.swift
//  wakatoonSDK
//
//  Created by bs-mac-4 on 15/12/22.
//

import UIKit


class eulaSDKPopUPViewController: UIViewController {

    //MARK: - VARIABLES
    var callBack: ((_ isAccept: Bool)->())?
    
    //MARK: - OUTLETS
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    
    @IBOutlet weak var checkUncheckBtn: UIButton!
    @IBOutlet weak var termsLbl: UILabel!
    
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var continueBtn: UIButton!
    //MARK: - LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    
    private func setupView() {
        titleLbl.text = "eula_sdk_popup_title".localized
        termsLbl.text = "eula_sdk_popup_condition".localized
        "eula_sdk_popup_description".localized.attributedStringFromHTML(completionBlock: { string in
            if let attributedString = string {
                let formattedText = attributedString.string.format(strings: ["eula_sdk_popup_termes_of_use".localized,"eula_sdk_popup_privacy_policy".localized], inString: attributedString.string)
                descLbl.attributedText = formattedText
                let tap = UITapGestureRecognizer(target: self, action: #selector(handleTermTapped))
                descLbl.addGestureRecognizer(tap)
                descLbl.isUserInteractionEnabled = true
                descLbl.textAlignment = .center
            }
        })
        backBtn.setTitle("back".localized, for: .normal)
        continueBtn.setTitle("continue".localized, for: .normal)
        titleLbl.font = getFont(size: 15, style: .Regular)
        termsLbl.font = getFont(size: 12, style: .Regular)
        descLbl.font = getFont(size: 12, style: .Regular)
        
        checkUncheckBtn.isSelected = false
        checkUncheckBtn.setImage(UIImage(named: "\(checkUncheckBtn.isSelected ? "checkbox" : "unchecked")", in: Bundle(for: type(of: self)), compatibleWith: nil)!, for: .normal)
        checkUncheckBtn.tintColor = isDarkMode() ? .white : .black
    }
    
    @objc func handleTermTapped(gesture: UITapGestureRecognizer) {
        let termString = self.descLbl.attributedText!.string as NSString
        let termRange = termString.range(of: "eula_sdk_popup_termes_of_use".localized)
        let policyRange = termString.range(of: "eula_sdk_popup_privacy_policy".localized)
        
        let tapLocation = gesture.location(in: descLbl)
        let index = descLbl.indexOfAttributedTextCharacterAtPoint(point: tapLocation)
        
        if checkRange(termRange, contain: index) == true {
            UIApplication.shared.open(URL(string: WakatoonSDKData.shared.termsURL)!)
            return
        }
        
        if checkRange(policyRange, contain: index) {
            let original = WakatoonSDKData.shared.privacyPolicyURL
            if let encoded = original.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed), let url = URL(string: encoded) {
                UIApplication.shared.open(url)
            }
            return
        }
    }
    
    func checkRange(_ range: NSRange, contain index: Int) -> Bool {
        return index > range.location && index < range.location + range.length
    }
    
    //MARK: - BTNS ACTIONS
   
    @IBAction func continueBtnAction(_ sender: UIButton) {
        if checkUncheckBtn.isSelected, let callBack = callBack {
            callBack(true)
        }
    }
    
    @IBAction func backBtnAction(_ sender: UIButton) {
        if let callBack = callBack {
            callBack(false)
        }
    }
    
    @IBAction func checkUncheckBtnAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        sender.setImage(UIImage(named: "\(sender.isSelected ? "checkbox" : "unchecked")", in: Bundle(for: type(of: self)), compatibleWith: nil)!, for: .normal)
        sender.tintColor = isDarkMode() ? .white : .black
    }
    
}

