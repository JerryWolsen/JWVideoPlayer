//
//  JWVideoControlView.swift
//  JWVideoPlayer
//
//  Created by Wolsen on 2019/5/16.
//  Copyright © 2019 Wolsen. All rights reserved.
//

import UIKit

protocol JWProgresSliderDelegate: class {
    func player(controlView:JWVideoControlView, sliderTouchUpOut slider:UISlider)
}

class JWVideoControlView: UIView {
    
    typealias Block = () -> ()
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    weak var delegate: JWProgresSliderDelegate?
    
    var playBtnBlock: Block = {() in print("hello")}
    var isSliding = false
    
    static func create() -> JWVideoControlView {
        let view = Bundle.main.loadNibNamed("JWVideoControlView", owner: nil, options: nil)![0] as! JWVideoControlView
        return view
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    func updateCurrentTime(currentTime: TimeInterval) {
        if currentTimeLabel != nil {
            currentTimeLabel.text = JWTools.formatPlayTime(seconds: currentTime)
        }
    }
    
    func updateTotalTime(totalTime: TimeInterval) {
        if (totalTimeLabel != nil) && (totalTimeLabel.text == "00:00") {
            totalTimeLabel.text = JWTools.formatPlayTime(seconds: totalTime)
        }
    }
    
    func updateProgress(ratio: Float) {
        if (slider != nil) && (!isSliding) {
            slider.value = ratio
        }
    }
    
    private func setupView() {
       setupSlider()
       setupCurrentLabel()
       setupTotalTimeLabel()
    }
    
    private func setupSlider() {
        self.slider.setThumbImage(UIImage(named: "ProgressBar_Normal"), for: UIControl.State.normal)
        self.slider.setThumbImage(UIImage(named: "ProgressBar_Highlighted"), for: UIControl.State.highlighted)
        self.slider.setThumbImage(UIImage(named: "ProgressBar_Disabled"), for: UIControl.State.disabled)
    
        self.slider.minimumValue = 0
        self.slider.maximumValue = 1
        self.slider.value = 0
        self.slider.addTarget(self, action: #selector(onSliderTouchDown), for: .touchDown)
        self.slider.addTarget(self, action: #selector(onSliderTouchUp), for: .touchUpInside)
        self.slider.addTarget(self, action: #selector(onSliderTouchUp), for: .touchCancel)
        self.slider.addTarget(self, action: #selector(onSliderTouchUp), for: .touchUpOutside)
    }
    
    private func setupCurrentLabel() {
        self.currentTimeLabel.textColor = .green
        self.currentTimeLabel.font.withSize(12)
        self.currentTimeLabel.text = "00:00"
        self.currentTimeLabel.textAlignment = .right
    }
    
    private func setupTotalTimeLabel() {
        self.totalTimeLabel.textColor = .white
        self.totalTimeLabel.text = "00:00"
        self.totalTimeLabel.textAlignment = .left
    }
    
    @IBAction func onPlayBtnClicked(_ sender: Any) {
        NSLog("click play btn")
        playBtnBlock()
    }
    
    @objc private func onSliderTouchDown() {
        self.isSliding = true
    }
    
    @objc private func onSliderTouchUp() {
        self.delegate?.player(controlView: self, sliderTouchUpOut: self.slider)
    }
    
}
