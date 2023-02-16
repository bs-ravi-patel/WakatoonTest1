//
//  EnterNameViewController.swift
//  wakatoonSDK
//
//  Created by bs-mac-4 on 23/12/22.
//

import UIKit

class EnterNameViewController: BaseViewController {
    
    //MARK: - VARIABLES
    var name: ((_ name: String)->())?
    var keyboardTF: UITextField?
    
    //MARK: - OUTLETS
    @IBOutlet weak var whoTheArtistLbl: UILabel!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var cancleBtn: UIButton!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var centerContraint: NSLayoutConstraint!
    
    //MARK: - LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        addDoneButtonOnKeyboard()
        nameTF.delegate = self
    }
    
    static func FromStoryBoard() -> Self {
        return  EnterNameViewController(nibName: "EnterNameViewController", bundle: Bundle(for: EnterNameViewController.self)) as! Self
    }

    private func setupView() {
        whoTheArtistLbl.text = "who_the_artist".localized
        cancleBtn.setTitle("cancel".localized, for: .normal)
        continueBtn.setTitle("continue".localized, for: .normal)
        if let name = Common.getPreviousName() {
            nameTF.text = name
        }else {
            nameTF.text = WakatoonSDKData.shared.PROFILE_ID
        }
    }
    
    //MARK: - BTNS ACTIONS
    @IBAction func btnsActions(_ sender: UIButton) {
        nameTF.endEditing(true)
        if sender.tag == 0 {
            dismiss(animated: true)
        }else {
            Common.setPreviousName(nameTF.text ?? "")
            dismiss(animated: false) {
                self.name?((self.nameTF.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }
    }
    
    func addDoneButtonOnKeyboard() {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let textfield = UITextField()
        let textfieldBarButton = UIBarButtonItem.init(customView: textfield)
        textfield.frame = CGRect(x: 0, y: 5, width: UIScreen.main.bounds.width-200, height: 30)
        textfield.setLeftPadding(padding: 15)
        textfield.text = nameTF.text ?? ""
        textfield.borderStyle = .roundedRect
        textfield.clearButtonMode = .always
        keyboardTF = textfield
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        
        keyboardToolbar.items = [textfieldBarButton,flexibleSpace , doneButton]
        nameTF.inputAccessoryView = keyboardToolbar
    }
    
    @objc func dismissKeyboard() {
        nameTF.resignFirstResponder()
        keyboardTF?.resignFirstResponder()
        view.endEditing(true)
        if let TF = keyboardTF, let newText = TF.text {
            nameTF.text = newText
        }
    }
    
}

extension EnterNameViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        DispatchQueue.main.async { [weak self] in
            if textField == self?.nameTF && self?.nameTF.isEditing == true {
                self?.keyboardTF?.becomeFirstResponder()
            }
        }
        return true
    }
    
}
