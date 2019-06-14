//
//  UIView+Utils.swift
//  JWVideoPlayer
//
//  Created by Wolsen on 2019/6/14.
//  Copyright © 2019 Wolsen. All rights reserved.
//

import UIKit

extension UIView {
    func parentVC() -> UIViewController? {
        var next = self.next
        while next != nil {
            if next is UIViewController {
                return next as? UIViewController
            }
            next = next?.next
        }
        print("not found")
        return nil
    }
}
