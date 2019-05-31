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
    
    var statusBarStyle: UIStatusBarStyle = .default {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    // MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupView()
        playVideo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.statusBarStyle
    }
    
    deinit {
        NSLog("deinit PlayerVC")
    }
    
    // MARK: public method
    func setupParameters(result: PHFetchResult<PHAsset>, index: Int) {
        asset = result
        currentIndex = index
    }
    
    // MARK: private method
    private func setupNavigation() {
        navigationController?.isNavigationBarHidden = true
        navigationController?.isToolbarHidden = true
    }
    
    private func setupView() {
        view.backgroundColor = .white
        playerView = JWVideoPlayerView()
        view.addSubview(playerView)
        playerView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        playerView.singleTapBlock = { [weak self]() in
            if let isBarHidden = self?.navigationController?.isNavigationBarHidden {
                self?.navigationController?.setNavigationBarHidden(!isBarHidden, animated: true)
                self?.statusBarStyle = (!isBarHidden) ? .default : .lightContent
            }
        }
        let filename = currentAsset.value(forKey: "filename")
        title = filename as? String
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
            }
        }
    }
    
}

