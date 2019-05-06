//
//  JWBaseNavigationController.swift
//  JWVideoPlayer
//
//  Created by Wolsen on 2019/5/6.
//  Copyright © 2019 Wolsen. All rights reserved.
//

import UIKit

class JWBaseNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        isToolbarHidden = false
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

}
