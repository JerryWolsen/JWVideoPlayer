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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigation()
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
        playVideo()
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
            }
        }
    }
    
    func setupParameters(result: PHFetchResult<PHAsset>, index: Int) {
        asset = result
        currentIndex = index
    }
    
}
