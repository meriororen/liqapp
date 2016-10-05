//
//  UIButton+Text.swift
//  liqapp
//
//  Created by Isa Ansharullah on 10/5/16.
//  Copyright © 2016 DuldulStudio. All rights reserved.
//

import UIKit

extension UIButton {
    var text: String? {
        get {
            return self.currentTitle
        }
        set(new) {
            self.setTitle(new, for: .normal)
        }
    }
}
