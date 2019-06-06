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
    func nextVideo(controlView:JWVideoControlView)
    func previousVideo(controlView:JWVideoControlView)
}

enum PlayMode: Int {
    case sequence = 1
    case listRepeat
    case singleRepeat
}

class JWVideoControlView: UIView {
    
    typealias Block = () -> ()
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playModeButton: UIButton!
    
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var normalSpeedButton: UIButton!
    @IBOutlet weak var threeOfFourSpeedButton: UIButton!
    @IBOutlet weak var halfSpeedButton: UIButton!
    @IBOutlet weak var oneAndHalfSpeedButton: UIButton!
    @IBOutlet weak var twiceSpeedButton: UIButton!
    
    weak var delegate: JWProgresSliderDelegate?
    
    var playBtnBlock: Block = {}
    var isSliding = false
    
    private var playMode = PlayMode.sequence
    
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
    
    func resetTotalTime() {
        totalTimeLabel.text = "00:00"
    }
    
    func updateProgress(ratio: Float) {
        if (slider != nil) && (!isSliding) {
            slider.value = ratio
        }
    }
    
    func getPlayMode() -> PlayMode{
        return self.playMode
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
        self.currentTimeLabel.font.withSize(12)
        self.currentTimeLabel.text = "00:00"
        self.currentTimeLabel.textAlignment = .right
    }
    
    private func setupTotalTimeLabel() {
        self.totalTimeLabel.text = "00:00"
        self.totalTimeLabel.textAlignment = .left
    }
    
    @objc private func onSliderTouchDown() {
        self.isSliding = true
    }
    
    @objc private func onSliderTouchUp() {
        self.delegate?.player(controlView: self, sliderTouchUpOut: self.slider)
    }
    
    @IBAction private func onPlayBtnClicked(_ sender: UIButton) {
        NSLog("click play btn")
        playBtnBlock()
    }
    
    @IBAction private func onPlayModeButtonClicked(_ sender: UIButton) {
        NSLog("click play mode \(self.playMode)")
        self.playMode = PlayMode(rawValue: (self.playMode.rawValue + 1) % 4) ?? .sequence
        var playModeButtonImageName = ""
        switch playMode {
        case .sequence:
            playModeButtonImageName = "sequence"
            break
        case .listRepeat:
            playModeButtonImageName = "repeat"
            break
        case .singleRepeat:
            playModeButtonImageName = "repeat_single"
            break
        }
        self.playModeButton.setImage(UIImage(named: playModeButtonImageName), for: .normal)
    }
    
    @IBAction func onClickHalfSpeenButton(_ sender: UIButton) {
    }
    
    @IBAction func onClickThreeOfFourSpeedButton(_ sender: UIButton) {
    }
    
    @IBAction func onClickNormalSpeedButton(_ sender: UIButton) {
    }
    
    @IBAction func onClickOneAndHalfSpeedButton(_ sender: UIButton) {
    }
    
    @IBAction func onClickTwiceSpeedButton(_ sender: UIButton) {
    }
    
    @IBAction func onClickPreviousButton(_ sender: UIButton) {
        self.delegate?.previousVideo(controlView: self)
    }
    
    @IBAction func onClickNextButton(_ sender: UIButton) {
        self.delegate?.nextVideo(controlView: self)
    }
}
