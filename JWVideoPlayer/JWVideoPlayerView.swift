//
//  JWVideoPlayerView.swift
//  JWVideoPlayer
//
//  Created by Wolsen on 2019/5/7.
//  Copyright © 2019 Wolsen. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer

protocol JWVideoPlayerDelegate: class {
    func player(playerView:JWVideoPlayerView, sliderTouchUpOut slider:UISlider)
}

class JWVideoPlayerView: UIView {
    
    
    var isPlaying: Bool = false
    var doubleTap: UITapGestureRecognizer!
    var pan: UIPanGestureRecognizer!
    var light: CGFloat! {
        didSet {
            NSLog("%.2f", light)
            UIScreen.main.brightness = light ?? 0.5
        }
    }
    var voiceView: MPVolumeView!
    var volumeSlider: UISlider!
    weak var delegate: JWVideoPlayerDelegate?
    
    private var playerLayer: AVPlayerLayer!
    private var playerItem: AVPlayerItem?
    private var playButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        doubleTap = UITapGestureRecognizer.init(target: self, action: #selector(handleDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTap)
        self.backgroundColor = UIColor(red: 233/255, green: 1, blue: 1, alpha: 0.5)
        
        light = UIScreen.main.brightness
        
        voiceView = MPVolumeView(frame: self.bounds)
        for subview in voiceView.subviews {
            if let slider = subview as? UISlider {
                volumeSlider = slider
                break
            }
        }
        voiceView.isHidden = true
        self.addSubview(voiceView)
        pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(pan:)))
        self.addGestureRecognizer(pan)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.removeGestureRecognizer(doubleTap)
        self.removeGestureRecognizer(pan)
    }
    
    func setupPlayerLayer(playerItem: AVPlayerItem) {
        self.playerItem = playerItem
        let player = AVPlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspect
        playerLayer.frame = self.layer.bounds
        self.layer.addSublayer(playerLayer)
    }
    
    func play() {
        playerLayer.player!.play()
        isPlaying = true
    }
    
    func pause() {
        playerLayer.player!.pause()
        isPlaying = false
    }
    
    func status() -> AVPlayer.Status {
        return playerLayer.player!.status
    }
    
    func seekToTime(time: CMTime, completeHandler: @escaping (Bool) -> Void ) {
        playerLayer.player!.seek(to: time, completionHandler: completeHandler)
    }
    
    func currentTime() -> Float64 {
        return CMTimeGetSeconds(playerLayer.player?.currentTime() ?? CMTime(value: 0, timescale: 1))
    }
    
    func totalTime() -> Float64{
        let duration = playerItem?.duration ?? CMTime(value: 0, timescale: 1)
        guard duration.value != 0 else {
            return 0
        }
        return  TimeInterval(duration.value) / TimeInterval(duration.timescale)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard playerLayer != nil else {
            return
        }
        playerLayer.frame = self.layer.bounds
    }
    
    @objc private func handleDoubleTap() {
        if isPlaying == true {
            showPlayButton()
            pause()
        } else {
            hidePlayButton()
            play()
        }
    }
    
    @objc private func handlePan(pan: UIPanGestureRecognizer) {
        let movePoint = pan.translation(in: pan.view)
        let absX = abs(movePoint.x)
        let absY = abs(movePoint.y)
        
        let locationPoint = pan.location(in: pan.view)
        
        if absX > absY {
            if movePoint.x < 0 {
                NSLog("向左滑动")
            } else {
                NSLog("向右滑动")
            }
            
        } else {
            
            if locationPoint.x < (self.frame.width / 2) {
                if movePoint.y < 0 {
                    if light.isLess(than: 1) {
                        light = light + 0.02
                    } else {
                        light = 1
                    }
                } else {
                    light = light - 0.02
                    if light.isLess(than: 0){
                        light = 0
                    }
                }
            } else {
                let volume = self.volumeSlider.value
                NSLog("%2f", volume)
                if movePoint.y < 0 {
                    if volume.isLess(than: 1) {
                        self.volumeSlider.value = volume + 0.01
                    } else {
                        self.volumeSlider.value = 1
                    }
                } else {
                    self.volumeSlider.value = volume - 0.01
                    if self.volumeSlider.value.isLess(than: 0){
                        self.volumeSlider.value = 0
                    }
                }
            }
        }
    }
    
    private func showPlayButton() {
        
        guard playButton == nil else {
            playButton.isHidden = false
            return
        }
        
        playButton = UIButton(type: .custom)
        self.addSubview(playButton)
        playButton.setBackgroundImage(UIImage(named: "play_button"), for: .normal)
        playButton.addTarget(self, action: #selector(onPlayBtnClicked), for: .touchUpInside)
        playButton.snp.makeConstraints { (make) in
            make.center.equalTo(self)
            make.width.equalTo(80)
            make.height.equalTo(80)
        }
        
    }
    
    private func hidePlayButton() {
        
        playButton.isHidden = true
        
    }
    
    @objc private func onPlayBtnClicked() {
        hidePlayButton()
        play()
    }
    
}
