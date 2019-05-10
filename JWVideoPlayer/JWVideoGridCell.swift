//
//  JWVideoGridCell.swift
//  JWVideoPlayer
//
//  Created by Wolsen on 2019/5/5.
//  Copyright © 2019 Wolsen. All rights reserved.
//

import UIKit
import SnapKit

class JWVideoGridCell: UICollectionViewCell {
    
    var imageView: UIImageView!
    var durationLabel: UILabel!
    var representedAssetIdentifier: String!
    var bottomBgView: UIView!
    
    var thumbnailImage: UIImage! {
        didSet {
            imageView.image = thumbnailImage
        }
    }
    
    var duration: String! {
        didSet {
            durationLabel.text = duration
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        self.backgroundColor = UIColor.red
        self.clipsToBounds = true
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        imageView.contentMode = .scaleAspectFill
        self.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
        bottomBgView = UIView()
        self.addSubview(bottomBgView)
        bottomBgView.snp.makeConstraints { (make) in
            make.bottom.equalTo(self)
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.height.equalTo(15)
        }
    
        durationLabel = UILabel()
        bottomBgView.addSubview(durationLabel)
        durationLabel.textAlignment = .right
        durationLabel.snp.makeConstraints { (make) in
            make.right.equalTo(self).inset(5)
            make.bottom.equalTo(self)
        }
        durationLabel.textColor = UIColor.white
        durationLabel.font = UIFont.systemFont(ofSize: 13)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let gradientLayer = JWTools.addGradientLayer(topColor: UIColor.clear.cgColor, bottomColor: UIColor.black.cgColor, frame: bottomBgView.bounds)
        bottomBgView.layer.insertSublayer(gradientLayer, at: 0)
    
    }
}
