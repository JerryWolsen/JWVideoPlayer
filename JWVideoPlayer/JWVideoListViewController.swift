//
//  JWVideoListsViewController.swift
//  JWVideoPlayer
//
//  Created by Wolsen on 2019/5/5.
//  Copyright © 2019 Wolsen. All rights reserved.
//

import UIKit
import SnapKit
import Photos

class JWVideoListViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    var allVideos: PHFetchResult<PHAssetCollection>!
    var asset: PHFetchResult<PHAsset>!
    var availableWidth: CGFloat = 0
    
    var collectionViewFlowLayout: UICollectionViewFlowLayout!
    var collectionView: UICollectionView!
    
    fileprivate let imageManager = PHCachingImageManager()
    fileprivate var thumbnailSize: CGSize!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "本地视频列表"
        view.backgroundColor = UIColor.white
        allVideos = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumVideos, options: nil)
        
        asset = PHAsset.fetchAssets(in: allVideos.object(at: 0), options: nil)
        PHPhotoLibrary.shared().register(self)
        
        let width = view.bounds.inset(by: view.safeAreaInsets).width
        let height = view.bounds.inset(by: view.safeAreaInsets).height
        collectionViewFlowLayout = UICollectionViewFlowLayout.init()
        collectionViewFlowLayout.scrollDirection = .vertical
        collectionViewFlowLayout.minimumLineSpacing = 1
        collectionViewFlowLayout.minimumInteritemSpacing = 1
        collectionViewFlowLayout.itemSize = CGSize(width: 80, height: 80)
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: width, height: height), collectionViewLayout: collectionViewFlowLayout)
        
        //注册一个cell
        collectionView.register(JWVideoGridCell.self, forCellWithReuseIdentifier:"JWVideoGridCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.white
        self.view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.left.equalTo(view.safeAreaLayoutGuide.snp.left)
            make.right.equalTo(view.safeAreaLayoutGuide.snp.right)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let width = view.bounds.inset(by: view.safeAreaInsets).width
        if availableWidth != width {
            availableWidth = width
            let columnCount = (width / 80).rounded(.towardZero)
            let itemLength = (width - columnCount - 1) / columnCount
            //设置每一个cell的宽高
            collectionViewFlowLayout.itemSize = CGSize(width: itemLength, height: itemLength)
            collectionViewFlowLayout.invalidateLayout()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let scale = UIScreen.main.scale
        let cellSize = collectionViewFlowLayout.itemSize
        thumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    // MARK: Collection View
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return asset.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let assetItem = asset.object(at: indexPath.item)
       
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "JWVideoGridCell", for: indexPath) as? JWVideoGridCell else {
            fatalError("Unexpected cell in collection view")
        }
        cell.representedAssetIdentifier = assetItem.localIdentifier
        imageManager.requestImage(for: assetItem, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { (image, _) in
            if cell.representedAssetIdentifier == assetItem.localIdentifier {
                cell.thumbnailImage = image
            }
        })
        cell.duration = JWTools.formatPlayTime(seconds: assetItem.duration)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc: JWVideoPlayerController = JWVideoPlayerController()
        vc.setupParameters(result: asset, index: indexPath.item)
        navigationController?.pushViewController(vc, animated: true)
    }
}


extension JWVideoListViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
    }
    
}

