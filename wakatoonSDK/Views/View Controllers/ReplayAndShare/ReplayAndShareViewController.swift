//
//  ReplayAndShareViewController.swift
//  wakatoonSDK
//
//  Created by bs-mac-4 on 02/01/23.
//

import UIKit

class ReplayAndShareViewController: BaseViewController {

    //MARK: - VARIABLES
    var replayCallback: (()->())?
    var nextEpisodeCallback: (()->())?
    var closeCallback: (()->())?
    
    //MARK: - OUTLETS
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var screenTitleLbl: UILabel!
    @IBOutlet weak var replayBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var nextButtonView: UIView!
    
    //MARK: - LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    static func FromStoryBoard() -> Self {
        return  ReplayAndShareViewController(nibName: "ReplayAndShareViewController", bundle: Bundle(for: ReplayAndShareViewController.self)) as! Self
    }
    
    //MARK: - SETUP VIEW -
    private func setupView() {
        let backImage = UIImage(named: "close", in: Bundle(for: type(of: self)), compatibleWith: nil)?.imageWithColor(color: .systemTeal)
        closeBtn.setImage(backImage, for: .normal)
        closeBtn.setImage(backImage, for: .highlighted)
        
        screenTitleLbl.text = "replay_your_personalized_animated_film".localized
        replayBtn.setTitle("replay".localized, for: .normal)
        nextBtn.setTitle("next".localized, for: .normal)
        
        screenTitleLbl.font = getFont(size: 17, style: .SemiBold)
        replayBtn.titleLabel?.font = getFont(size: 16, style: .Medium)
        nextBtn.titleLabel?.font = getFont(size: 16, style: .Medium)
        
        nextButtonView.isHidden = WakatoonSDKData.shared.totalEpisode == WakatoonSDKData.shared.currentEpisodeID
        
    }
    
    //MARK: - BTNS ACTIONS
    @IBAction func closeBtnAction(_ sender: UIButton) {
        guard let closeCallback = self.closeCallback else { return }
        closeCallback()
        dismiss(animated: false)
    }
    
    @IBAction func replayBtnAction(_ sender: UIButton) {
        guard let replayCallback = self.replayCallback else { return }
        replayCallback()
        dismiss(animated: false)
    }
    
    @IBAction func nextBtnAction(_ sender: UIButton) {
        guard let nextEpisodeCallback = self.nextEpisodeCallback else { return }
        nextEpisodeCallback()
        dismiss(animated: true)
    }
    
}
