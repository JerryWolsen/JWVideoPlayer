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
        navigationBar.isTranslucent = true
        navigationBar.barStyle = .black
        navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    override var childForStatusBarStyle: UIViewController? {
        return self.topViewController
    }
}
