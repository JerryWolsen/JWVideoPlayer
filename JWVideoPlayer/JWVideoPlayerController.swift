//
//  JWVideoPlayerController.swift
//  JWVideoPlayer
//
//  Created by Wolsen on 2019/5/7.
//  Copyright © 2019 Wolsen. All rights reserved.
//

import UIKit
import Photos
import SnapKit

class JWVideoPlayerController: UIViewController {

    var asset: PHFetchResult<PHAsset>!
    var currentAsset: PHAsset!
    var currentIndex: Int! {
        didSet {
            currentAsset = asset.object(at: currentIndex)
        }
    }
    var playerView: JWVideoPlayerView!
    var singleTap: UITapGestureRecognizer!
    var slider: UISlider!
    var isSliding: Bool = false
    var currentTimeLabel: UILabel!
    var totalTimeLabel: UILabel!
    var link: CADisplayLink!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigation()
        playVideo()
      
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        guard slider != nil else {
            return
        }
        let direction = UIDevice.current.orientation
        NSLog("%f", view.bounds.width)
        let otherWidth = direction == .portrait ? 200 : 300
        self.slider.frame = CGRect(x: 0, y: 0, width: Int(view.bounds.width) - otherWidth, height: 50)
    }
    
    @objc private func update() {
        let currentTime = playerView.currentTime()
        let totalTime = playerView.totalTime()
        if currentTimeLabel != nil {
            currentTimeLabel.text = formatPlayTime(seconds: currentTime)
        }
        if (totalTimeLabel != nil) && (totalTimeLabel.text == "00:00") {
            totalTimeLabel.text = formatPlayTime(seconds: totalTime)
        }
        if (slider != nil) && (!isSliding) {
            slider.value = Float(currentTime / totalTime)
        }
    }
    
    private func setupNavigation() {
        navigationController?.isNavigationBarHidden = true
        navigationController?.isToolbarHidden = true
        singleTap = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap))
        self.view.addGestureRecognizer(singleTap)
        singleTap.require(toFail: playerView.doubleTap)
    }
    
    @objc func handleSingleTap() {
        navigationController?.isNavigationBarHidden = !((navigationController?.isNavigationBarHidden)!)
        navigationController?.isToolbarHidden = !((navigationController?.isToolbarHidden)!)
        
        if navigationController?.isToolbarHidden == false {
            guard self.slider == nil else {
                return
            }
            self.slider = UISlider()
            self.slider.minimumValue = 0
            self.slider.maximumValue = 1
            self.slider.value = 0
            self.slider.addTarget(self, action: #selector(onSliderTouchDown), for: .touchDown)
            self.slider.addTarget(self, action: #selector(onSliderTouchUp), for: .touchUpInside)
            self.slider.addTarget(self, action: #selector(onSliderTouchUp), for: .touchCancel)
            self.slider.addTarget(self, action: #selector(onSliderTouchUp), for: .touchUpOutside)
            let sliderItem = UIBarButtonItem(customView: self.slider)
            
            self.slider.frame = CGRect(x: 0, y: 0, width: view.bounds.width - 200, height: 50)
            
            self.currentTimeLabel = UILabel()
            self.currentTimeLabel.textColor = .blue
            //self.currentTimeLabel.backgroundColor = .red
            self.currentTimeLabel.font.withSize(12)
            self.currentTimeLabel.text = "00:00"
            self.currentTimeLabel.textAlignment = .right
            self.currentTimeLabel.snp.makeConstraints { (make) in
                make.width.equalTo(70)
            }
            let currentTimeItem = UIBarButtonItem(customView: self.currentTimeLabel)
            self.totalTimeLabel = UILabel()
            self.totalTimeLabel.textColor = .blue
            self.totalTimeLabel.text = "00:00"
            self.totalTimeLabel.textAlignment = .left
            self.totalTimeLabel.snp.makeConstraints { (make) in
                make.width.equalTo(70)
            }
            //totalTimeLabel.backgroundColor = .red
            let totalTimeItem = UIBarButtonItem(customView: self.totalTimeLabel)
            
            let fixedSpace1 = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
            fixedSpace1.width = 10
            let fixedSpace2 = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
            fixedSpace2.width = 10
            toolbarItems = [currentTimeItem, fixedSpace1, sliderItem, fixedSpace2, totalTimeItem]
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.link.invalidate()
    }
    
    deinit {
        self.view.removeGestureRecognizer(singleTap)
    }
    
    private func setupView() {
        view.backgroundColor = .white
       
        playerView = JWVideoPlayerView()
        view.addSubview(playerView)
        playerView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        playerView.delegate = self
        
    }
    
    private func playVideo() {
        
        guard currentAsset != nil else {
            return
        }
        
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .automatic
        
        PHImageManager.default().requestPlayerItem(forVideo: currentAsset, options: options) { playerItem, info  in
            DispatchQueue.main.sync {
                self.playerView.setupPlayerLayer(playerItem: playerItem!)
                self.playerView.play()
                self.link = CADisplayLink(target: self, selector: #selector(self.update))
                self.link.add(to: .main, forMode: .default)
            }
        }
    }
    
    func setupParameters(result: PHFetchResult<PHAsset>, index: Int) {
        asset = result
        currentIndex = index
    }
    
    func formatPlayTime(seconds: TimeInterval) -> String {
        if seconds.isNaN {
            return "00:00"
        }
        let Min = Int(seconds / 60)
        let Sec = Int(seconds.truncatingRemainder(dividingBy: 60))
        if Min < 60 {
            return String(format: "%02d:%02d", Min, Sec)
        }
        let Hour = Int(Min / 60)
        let MinLeft = Int(Min % 60)
        return String(format: "%02d:%02d:%02d", Hour, MinLeft, Sec)
    }
    
    @objc func onSliderTouchDown() {
        self.isSliding = true
    }
    
    @objc func onSliderTouchUp() {
        self.playerView.delegate?.player(playerView: self.playerView, sliderTouchUpOut: self.slider)
    }
}

extension JWVideoPlayerController: JWVideoPlayerDelegate {
    func player(playerView: JWVideoPlayerView, sliderTouchUpOut slider: UISlider) {
        if playerView.status() == AVPlayer.Status.readyToPlay{
            let duration = slider.value * Float(playerView.totalTime())
            let seekTime = CMTimeMake(value: Int64(duration), timescale: 1)
            playerView.seekToTime(time:seekTime, completeHandler: { (status) in
                if status {
                    self.isSliding = false
                } else {
                    NSLog("进度跳转出错")
                }
            })
        }
    }
}
