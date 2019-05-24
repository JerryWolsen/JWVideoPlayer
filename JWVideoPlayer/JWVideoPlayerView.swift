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
    
    // MARK: public var
    var isPlaying: Bool = false
    weak var delegate: JWVideoPlayerDelegate?
    
    // MARK: private var
    private var pan: UIPanGestureRecognizer!
    private var light: CGFloat! {
        didSet {
            NSLog("%.2f", light)
            UIScreen.main.brightness = light ?? 0.5
        }
    }
    private var doubleTap: UITapGestureRecognizer!
    private var singleTap: UITapGestureRecognizer!
    private var voiceView: MPVolumeView!
    private var volumeSlider: UISlider!
    private var playerLayer: AVPlayerLayer!
    private var playerItem: AVPlayerItem?
    private var playButton: UIButton!
    private var width = UIScreen.main.bounds.width
    private lazy var controlView: JWVideoControlView = {
        let controlView: JWVideoControlView = JWVideoControlView.create()
        self.addSubview(controlView)
        controlView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(100)
        }
        controlView.playBtnBlock = { [weak self]() in
            let imageName = self?.isPlaying == true ? "Play" : "Pause"
            self?.controlView.playButton.setImage(UIImage(named: imageName), for: .normal)
            self?.isPlaying == true ? self?.pause() : self?.play()
        }
        return controlView
    }()
    private lazy var progressView: JWProgressView = {
        let pv = JWProgressView()
        self.addSubview(pv)
        pv.snp.makeConstraints({ (make) in
            make.centerX.equalTo(self)
            make.top.equalTo(self).inset(120)
            make.width.equalTo(200)
            make.height.equalTo(100)
        })
        return pv
    }()
    private let preferTimeScale: CMTimeScale = 600
    
    // MARK: life cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
        } catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
       
        self.backgroundColor = UIColor(red: 188.0/255, green: 188.0/255, blue: 188.0/255, alpha: 0.5)
        
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
       
        setupGestureHandlers()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard playerLayer != nil else {
            return
        }
        playerLayer.frame = self.layer.bounds
        width = self.bounds.width
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" && change != nil {
            let item: AVPlayerItem = object as! AVPlayerItem
            if item.status == .readyToPlay {
                NSLog("Jerry: play start")
                self.play()
            } else if item.status == .failed {
                NSLog("AVPlayerStatusFailed")
            } else {
                NSLog("AVPlayerStatusUnknown")
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.removeGestureRecognizer(doubleTap)
        self.removeGestureRecognizer(singleTap)
        self.removeGestureRecognizer(pan)
        NotificationCenter.default.removeObserver(self)
        playerItem?.removeObserver(self, forKeyPath: "status")
    }
    
    // MARK: public method
    func setupPlayerLayer(playerItem: AVPlayerItem) {
        self.playerItem = playerItem
        let player = AVPlayer(playerItem: playerItem)
        player.volume = 1
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspect
        playerLayer.frame = self.layer.bounds
        self.layer.addSublayer(playerLayer)
        
        playerItem.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new
            , context: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying(note:)), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
    }
    
    func play() {
        hidePlayButton()
        playerLayer.player!.play()
        isPlaying = true
        self.controlView.playButton.setImage(UIImage(named: "Pause"), for: .normal)
        self.controlView.isHidden = true
    }
    
    func pause() {
        showPlayButton()
        playerLayer.player!.pause()
        isPlaying = false
        self.controlView.playButton.setImage(UIImage(named: "Play"), for: .normal)
    }
    
    func status() -> AVPlayer.Status {
        return playerLayer.player!.status
    }
    
    func seekToTime(time: CMTime, completeHandler: @escaping (Bool) -> Void ) {
        playerLayer.player!.seek(to: time, completionHandler: completeHandler)
    }
    
    func currentTime() -> Float64 {
        return CMTimeGetSeconds(playerLayer.player?.currentTime() ?? CMTime(value: 0, timescale: preferTimeScale))
    }
    
    func totalTime() -> Float64{
        let duration = playerItem?.duration ?? CMTime(value: 0, timescale: preferTimeScale)
        guard duration.value != 0 else {
            return 0
        }
        return  TimeInterval(duration.value) / TimeInterval(duration.timescale)
    }
    
    // MARK: private method
    private func setupGestureHandlers() {
        
        doubleTap = UITapGestureRecognizer.init(target: self, action: #selector(handleDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTap)
        
        singleTap = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap))
        self.addGestureRecognizer(singleTap)
        singleTap.require(toFail: doubleTap)
        
        pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(pan:)))
        self.addGestureRecognizer(pan)
        
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
        guard playButton != nil else {
            return
        }
        playButton.isHidden = true
    }
    
    // MARK: objc selector method
    @objc private func playerDidFinishPlaying(note: NSNotification) {
        NSLog("Jerry: play end")
        self.isPlaying = false
    }
    
    @objc private func handleDoubleTap() {
       isPlaying == true ? pause() : play()
    }
    
    @objc private func handleSingleTap() {
        self.firstViewController()?.navigationController?.isNavigationBarHidden = !((self.firstViewController()?.navigationController?.isNavigationBarHidden)!)
        if self.subviews.contains(self.controlView) {
            self.controlView.isHidden = !self.controlView.isHidden
        } else {
            self.controlView.isHidden = false
        }
        
    }
    
    @objc private func handlePan(pan: UIPanGestureRecognizer) {
        let movePoint = pan.translation(in: pan.view)
        let absX = abs(movePoint.x)
        let absY = abs(movePoint.y)
        
        let locationPoint = pan.location(in: pan.view)
        
        if pan.state == .began {
            if absX > absY {
                progressView.show()
                progressView.totalTime = JWTools.formatPlayTime(seconds: totalTime())
                progressView.currentTime = JWTools.formatPlayTime(seconds: currentTime())
            }
        }
        
        if absX > absY {
            let tTime = totalTime()
            let cTime = currentTime()
            var moveTime = Double(absX / width) * totalTime() * 0.8
            var destinationTime = 0.0
            if movePoint.x < 0 {
                progressView.showFastBack()
              
                if cTime - moveTime < 0 {
                    moveTime = cTime
                }
                destinationTime = cTime - moveTime
                progressView.currentTime = JWTools.formatPlayTime(seconds: destinationTime)
            } else {
                progressView.showFastForward()
                if(cTime + moveTime > tTime) {
                    moveTime = tTime - cTime
                }
                destinationTime = cTime + moveTime
                progressView.currentTime = JWTools.formatPlayTime(seconds: destinationTime)
            }
            
            if pan.state == .ended {
                progressView.hide()
                self.seekToTime(time: CMTime(seconds: destinationTime, preferredTimescale: preferTimeScale), completeHandler: { (status) in
                        if status {
                            if !self.isPlaying {
                                self.play()
                            }
                        } else {
                            NSLog("seek error")
                        }
                })
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
    
    @objc private func onPlayBtnClicked() {
        play()
    }
    
}

extension JWVideoPlayerView {
    //返回该view所在VC
    func firstViewController() -> UIViewController? {
        for view in sequence(first: self.superview, next: { $0?.superview }) {
            if let responder = view?.next {
                if responder.isKind(of: UIViewController.self){
                    return responder as? UIViewController
                }
            }
        }
        return nil
    }
}
