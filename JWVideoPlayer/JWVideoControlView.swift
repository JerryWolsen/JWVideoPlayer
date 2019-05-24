//
//  JWVideoControlView.swift
//  JWVideoPlayer
//
//  Created by Wolsen on 2019/5/16.
//  Copyright © 2019 Wolsen. All rights reserved.
//

import UIKit

class JWVideoControlView: UIView {
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    typealias Block = () -> ()
    var playBtnBlock: Block = {() in print("hello")}
    
    @IBAction func onPlayBtnClicked(_ sender: Any) {
        NSLog("click play btn")
        playBtnBlock()
    }
    
    static func create() -> JWVideoControlView {
        let view = Bundle.main.loadNibNamed("JWVideoControlView", owner: nil, options: nil)![0] as! JWVideoControlView
        return view
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    private func setupView() {
        self.slider.setThumbImage(UIImage(named: "ProgressBar_Normal"), for: UIControl.State.normal)
        self.slider.setThumbImage(UIImage(named: "ProgressBar_Highlighted"), for: UIControl.State.highlighted)
        self.slider.setThumbImage(UIImage(named: "ProgressBar_Disabled"), for: UIControl.State.disabled)
    }
    
}
