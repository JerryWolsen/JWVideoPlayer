//
//  JWTools.swift
//  JWVideoPlayer
//
//  Created by Wolsen on 2019/5/10.
//  Copyright © 2019 Wolsen. All rights reserved.
//

import UIKit

class JWTools: NSObject {

    static func formatPlayTime(seconds: TimeInterval) -> String {
        if seconds.isNaN {
            return "00:00"
        }
        let Min = Int(seconds / 60)
        let Sec = Int(seconds.truncatingRemainder(dividingBy: 60))
        if Min < 60 {
            return String(format: "%02d:%02d", Min, Sec)
        }
        let Hour = Int(Min / 60)
        let MinLeft = Int(Min % 60)
        return String(format: "%02d:%02d:%02d", Hour, MinLeft, Sec)
    }
    
    static func addGradientLayer(topColor: CGColor, bottomColor: CGColor, frame: CGRect) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        let gradientLocations: [NSNumber] = [0.0, 1.0]
        gradientLayer.colors = [topColor, bottomColor]
        gradientLayer.locations = gradientLocations
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        gradientLayer.frame = frame
        return gradientLayer
    }
    
    static func showAlert(title: String, message: String, viewController: UIViewController, handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title , message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))
        viewController.present(alert, animated: true, completion: nil)
    }
}


