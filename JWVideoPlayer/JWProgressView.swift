//
//  JWProgressView.swift
//  JWVideoPlayer
//
//  Created by Wolsen on 2019/5/14.
//  Copyright © 2019 Wolsen. All rights reserved.
//

import UIKit
import SnapKit

class JWProgressView: UIView {

    private lazy var fastView: UIImageView = {
        let fv = UIImageView()
        self.addSubview(fv)
        fv.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.width.equalTo(60)
            make.height.equalTo(48)
        }
        return fv
    }()
    
    private lazy var currentTimeLabel: UILabel = {
      let lb = UILabel()
      self.addSubview(lb)
      lb.snp.makeConstraints({ (make) in
         make.centerX.equalToSuperview().offset(-40)
         make.top.equalTo(self.fastView.snp.bottom).offset(10)
      })
      lb.textColor = .green
      lb.textAlignment = .right
      return lb
    }()
    
    private lazy var divideLabel: UILabel = {
        let lb = UILabel()
        self.addSubview(lb)
        lb.snp.makeConstraints({ (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.fastView.snp.bottom).offset(10)
        })
        lb.textColor = .white
        lb.textAlignment = .center
        return lb
    }()
    
    private lazy var totalTimeLabel: UILabel = {
        let lb = UILabel()
        self.addSubview(lb)
        lb.snp.makeConstraints({ (make) in
            make.centerX.equalToSuperview().offset(40)
            make.top.equalTo(self.fastView.snp.bottom).offset(10)
        })
        lb.textColor = .white
        lb.textAlignment = .left
        return lb
    }()
    
    private lazy var forwardImg: UIImage = {
        return UIImage(named: "player_fast_forward") ?? UIImage()
    }()
    
    private lazy var backImg: UIImage = {
        return UIImage(named: "player_fast_back") ?? UIImage()
    }()
    
    var totalTime: String! {
        didSet {
            self.totalTimeLabel.text = totalTime
        }
    }
    
    var currentTime: String! {
        didSet {
            self.currentTimeLabel.text = currentTime
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
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        self.layer.cornerRadius = 20
        currentTimeLabel.text = "12:22"
        divideLabel.text = "/"
        totalTimeLabel.text = "1:22:33"
    }
    
    func showFastBack() {
        fastView.image = backImg
    }
    
    func showFastForward() {
        fastView.image = forwardImg
    }
    
    func show() {
        self.isHidden = false
    }
    
    func hide() {
        self.isHidden = true
    }
    
}
