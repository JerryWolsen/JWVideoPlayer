//
//  JWVideoPlayerView.swift
//  JWVideoPlayer
//
//  Created by Wolsen on 2019/5/7.
//  Copyright © 2019 Wolsen. All rights reserved.
//

import UIKit
import AVKit

class JWVideoPlayerView: UIView {
    
    
    var isPlaying: Bool = false
    var doubleTap: UITapGestureRecognizer!
    
    private var playerLayer: AVPlayerLayer!
    private var playButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        doubleTap = UITapGestureRecognizer.init(target: self, action: #selector(handleDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTap)
        self.backgroundColor = UIColor(red: 233/255, green: 1, blue: 1, alpha: 0.5)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.removeGestureRecognizer(doubleTap)
    }
    
    func setupPlayerLayer(playerItem: AVPlayerItem) {
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
