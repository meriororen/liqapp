//
//  UIView+SlideInFromBottom.swift
//  liqapp
//
//  Created by Isa Ansharullah on 9/25/16.
//  Copyright © 2016 DuldulStudio. All rights reserved.
//

import UIKit

extension UIView {
    func slideInFromBottom(_ duration: TimeInterval = 1.0, completionDelegate: CAAnimationDelegate? = nil) {
        let slideInFromBottomTransition = CATransition()
        
        if let delegate: CAAnimationDelegate = completionDelegate {
            slideInFromBottomTransition.delegate = delegate
        }
        
        slideInFromBottomTransition.type = kCATransitionPush
        slideInFromBottomTransition.subtype = kCATransitionFromBottom
        slideInFromBottomTransition.duration = duration
        slideInFromBottomTransition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        slideInFromBottomTransition.fillMode = kCAFillModeRemoved
        
        self.layer.add(slideInFromBottomTransition, forKey: "slideInFromBottomTransition")
    }
    
    func fadeIn(_ duration: TimeInterval = 1.0, completionDelegate: CAAnimationDelegate? = nil) {
        let fadeInTransition = CATransition()
        
        if let delegate: CAAnimationDelegate = completionDelegate {
            fadeInTransition.delegate = delegate
        }
        
        fadeInTransition.type = kCATransitionFade
        fadeInTransition.duration = duration
        
        self.layer.add(fadeInTransition, forKey: "fadeInTransition")
    }
    
    func expand(_ duration: TimeInterval = 1.0, completionDelegate: AnyObject? = nil) {
    }
}
