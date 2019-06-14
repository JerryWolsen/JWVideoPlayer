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

class JWVideoPlayerView: UIView {
    
    typealias Block = () -> ()
    
    // MARK: - public var
    var isPlaying: Bool = false
    var singleTapBlock: Block = {}
    var playEndBlock: (PlayMode) -> () = {(mode) in }
    var playNextBlock: Block = {}
    var playPreviousBlock: Block = {}
    
    // MARK: - private var
    private var link: CADisplayLink!
    private var pan: UIPanGestureRecognizer!
    private var doubleTap: UITapGestureRecognizer!
    private var singleTap: UITapGestureRecognizer!
    
    private var playerLayer: AVPlayerLayer!
    private var playerItem: AVPlayerItem?
    
    private var voiceView: MPVolumeView!
    private var volumeSlider: UISlider!
    private var playButton: UIButton!
    
    private var light: CGFloat! {
        didSet {
            NSLog("%.2f", light)
            UIScreen.main.brightness = light ?? 0.5
        }
    }

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
            if let StrongSelf = self {
                let imageName = StrongSelf.isPlaying == true ? "Play" : "Pause"
                StrongSelf.controlView.playButton.setImage(UIImage(named: imageName), for: .normal)
                StrongSelf.isPlaying == true ? StrongSelf.pause() : StrongSelf.play()
            }
        }
        controlView.layer.zPosition = 100
        controlView.delegate = self
        controlView.isHidden = true
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
    private lazy var lockButton: UIButton = {
        let lock = UIButton()
        self.addSubview(lock)
        lock.setImage(UIImage(named: "Unlock-Normal"), for: .normal)
        lock.snp.makeConstraints({ (make) in
            make.centerY.equalTo(self)
            make.left.equalTo(self).inset(44)
            make.width.equalTo(29)
            make.height.equalTo(27)
        })
        lock.addTarget(self, action: #selector(onLockButtonClicked), for: .touchUpInside)
        lock.isHidden = true
        return lock
    }()
    private lazy var cameraButton: UIButton = {
        let camera = UIButton()
        self.addSubview(camera)
        camera.setImage(UIImage(named: "white_camera"), for: .normal)
        camera.snp.makeConstraints({ (make) in
            make.centerY.equalTo(self)
            make.right.equalTo(self).inset(44)
            make.width.equalTo(43)
            make.height.equalTo(43)
        })
        camera.addTarget(self, action: #selector(onCameraButtonClicked), for: .touchUpInside)
        camera.isHidden = true
        return camera
    }()
    
    private var isLocked = false {
        didSet {
            self.controlView.isHidden = isLocked
            self.cameraButton.isHidden = isLocked
            self.singleTapBlock()
        }
    }
    private var screenWidth = UIScreen.main.bounds.width
    private let preferTimeScale: CMTimeScale = 600
    
    // MARK: - life cycle
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
       
        self.setupGestureHandlers()
        
        self.initControlView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard playerLayer != nil else {
            return
        }
        playerLayer.frame = self.layer.bounds
        screenWidth = self.bounds.width
        print(safeAreaInsets.left)
        if #available(iOS 11.0, *) {
            self.lockButton.snp.updateConstraints({ (make) in
                make.left.equalTo(self).inset(safeAreaInsets.left + 5)
            })
            self.cameraButton.snp.updateConstraints { (make) in
                make.right.equalTo(self).inset(safeAreaInsets.right + 5)
            }
        }
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
        self.resetPlayer()
    }
    
    // MARK: - public method
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
        
        self.link = CADisplayLink(target: self, selector: #selector(update))
        self.link.add(to: .main, forMode: .default)
    }
    
    func play() {
        hidePlayButton()
        playerLayer.player!.play()
        isPlaying = true
        self.controlView.playButton.setImage(UIImage(named: "Pause"), for: .normal)
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
    
    func totalTime() -> Float64 {
        let duration = playerItem?.duration ?? CMTime(value: 0, timescale: preferTimeScale)
        guard duration.value != 0 else {
            return 0
        }
        return  TimeInterval(duration.value) / TimeInterval(duration.timescale)
    }
    
    func resetPlayer() {
        self.playerLayer.player?.pause()
        self.isPlaying = false
        self.controlView.resetTotalTime()
        self.playerLayer.removeFromSuperlayer()
        NotificationCenter.default.removeObserver(self)
        playerItem?.removeObserver(self, forKeyPath: "status")
        self.link.remove(from: .main, forMode: .default)
        self.link.invalidate()
    }
    
    // MARK: - private method
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
    
    private func initControlView() {
        self.controlView.playButton.setImage(UIImage(named: "Pause"), for: .normal)
        self.controlView.isHidden = true
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
    
    private func initProgressView() {
        progressView.show()
        progressView.totalTime = JWTools.formatPlayTime(seconds: totalTime())
        progressView.currentTime = JWTools.formatPlayTime(seconds: currentTime())
    }
    
    private func calculateCurrentSeekTime(moveX: CGFloat) -> TimeInterval {
        let moveTime = Double(moveX / screenWidth) * totalTime() * 0.8
        var destinationTime = self.currentTime() + moveTime
        destinationTime = destinationTime < 0 ? 0 : destinationTime
        destinationTime = destinationTime > totalTime() ? totalTime() : destinationTime
        
        return destinationTime
    }
    
    private func handleHorizonalPan(moveX: CGFloat, state: UIPanGestureRecognizer.State) {
        
        if state == .began {
            initProgressView()
        }
        
        let currentSeekTime = calculateCurrentSeekTime(moveX: moveX)
        moveX > 0 ? progressView.showFastForward() : progressView.showFastBack()
        progressView.currentTime = JWTools.formatPlayTime(seconds: currentSeekTime)
        
        if state == .ended {
            progressView.hide()
            self.seekToTime(time: CMTime(seconds: currentSeekTime, preferredTimescale: preferTimeScale), completeHandler: { (status) in
                (status && !self.isPlaying) ? self.play() : NSLog("seek error")
            })
        }
    }
    
    private func handleVerticalPan(isLeft: Bool, moveY: CGFloat) {
        isLeft ? adjustLight(moveY: moveY) : adjustVolume(moveY: moveY)
    }
    
    private func adjustLight(moveY: CGFloat) {
        if moveY < 0 {
            light = light.isLess(than: 1) ? light + 0.02 : 1
        } else {
            light = light.isLess(than: 0) ? 0 : light - 0.02
        }
    }
    
    private func adjustVolume(moveY: CGFloat) {
        let volume = self.volumeSlider.value
        if moveY < 0 {
            self.volumeSlider.value = volume.isLess(than: 1) ? volume + 0.01 : 1
        } else {
            self.volumeSlider.value = volume.isLess(than: 0) ? 0 : volume - 0.01
        }
    }
    
    private func getCurrentVideoImage() -> UIImage{
        let generator = AVAssetImageGenerator(asset: self.playerItem!.asset)
        var time = playerLayer.player?.currentTime()
        let imageRef:CGImage = try! generator.copyCGImage(at: time!, actualTime: &time!)
        return UIImage(cgImage: imageRef)
    }
    
    // MARK: - objc selector method
    @objc private func update() {
        let currentTime = self.currentTime()
        let totalTime = self.totalTime()
    
        self.controlView.updateCurrentTime(currentTime: currentTime)
        self.controlView.updateTotalTime(totalTime: totalTime)
        self.controlView.updateProgress(ratio: Float(currentTime / totalTime))
    }
    
    @objc private func playerDidFinishPlaying(note: NSNotification) {
        NSLog("Jerry: play end")
        let playMode = self.controlView.getPlayMode()
        self.resetPlayer()
        self.playEndBlock(playMode)
    }
    
    @objc private func handleDoubleTap() {
       isPlaying == true ? pause() : play()
    }
    
    @objc private func handleSingleTap() {
        self.lockButton.isHidden = !self.lockButton.isHidden
        if !self.isLocked {
            self.cameraButton.isHidden = !self.cameraButton.isHidden
            self.controlView.isHidden = !self.controlView.isHidden
            singleTapBlock()
        }
    }
    
    @objc private func handlePan(pan: UIPanGestureRecognizer) {
        
        guard !self.isLocked else {
            return
        }
        
        let movePoint = pan.translation(in: pan.view)
        let locationPoint = pan.location(in: pan.view)
        let absX = abs(movePoint.x)
        let absY = abs(movePoint.y)
        
        if absX > absY {
            handleHorizonalPan(moveX: movePoint.x, state: pan.state)
        } else {
            handleVerticalPan(isLeft: locationPoint.x < (self.frame.width / 2), moveY: movePoint.y)
        }
    }
    
    @objc private func onPlayBtnClicked() {
        play()
    }
    
    @objc private func onLockButtonClicked() {
        self.isLocked = !self.isLocked
        let imageName = self.isLocked ? "Lock-Normal" : "Unlock-Normal"
        self.lockButton.setImage(UIImage(named: imageName), for: .normal)
    }
    
    @objc private func onCameraButtonClicked() {
        let image = self.getCurrentVideoImage()
         UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted(image:withError:contextInfo:)), nil)
    }
    
    @objc private func saveCompleted(image:UIImage, withError error:NSError?, contextInfo:UnsafeRawPointer){
        if let e = error as NSError? {
            print("Jerry save error: \(e)" )
        } else {
            print("Jerry: image saved successfully")
            JWTools.showAlert(title: "保存成功", message: "截图已保存至相册", viewController: self.parentVC()!, handler: nil)
        }
    }
    
}

extension JWVideoPlayerView: JWProgresSliderDelegate {
    func setPlayRate(rate: Float) {
        self.playerLayer.player?.rate = rate
    }
    
    func player(controlView: JWVideoControlView, sliderTouchUpOut slider: UISlider) {
        if self.status() == AVPlayer.Status.readyToPlay{
            let duration = slider.value * Float(self.totalTime())
            let seekTime = CMTime(seconds: Double(duration), preferredTimescale: 600)
            self.seekToTime(time:seekTime, completeHandler: {[weak self](status) in
                if status {
                    self?.controlView.isSliding = false
                    if !(self?.isPlaying ?? false) {
                        self?.play()
                    }
                } else {
                    NSLog("进度跳转出错")
                }
            })
        }
    }
    
    func nextVideo(controlView: JWVideoControlView) {
        self.resetPlayer()
        self.playNextBlock()
    }
    
    func previousVideo(controlView: JWVideoControlView) {
        self.resetPlayer()
        self.playPreviousBlock()
    }
}
