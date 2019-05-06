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
    
    var representedAssetIdentifier: String!
    
    var thumbnailImage: UIImage! {
        didSet {
            imageView.image = thumbnailImage
        }
    }
    
    override init(frame: CGRect) {
        super .init(frame: frame)
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
    }
}
