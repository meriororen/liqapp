//
//  UIAuthTextField.swift
//  liqapp
//
//  Created by Isa Ansharullah on 10/5/16.
//  Copyright © 2016 DuldulStudio. All rights reserved.
//

import UIKit


class UIAuthTextField: UITextField {
    
    enum UIAuthState {
        case authNormal, authError
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.authState = .authNormal
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.authState = .authNormal
    }
    
    var authState: UIAuthState {
        get {
            return self.authState
        }
        set(new) {
            if new == UIAuthState.authError { errorDisplay() }
        }
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + 10, y: bounds.origin.y, width: bounds.width, height: bounds.height)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + 10, y: bounds.origin.y, width: bounds.width, height: bounds.height)
    }
    
    func errorDisplay() {
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.red.cgColor
        self.layer.backgroundColor = UIColor(red: 203.0/255.0,
                                             green: 171.0/255.0,
                                             blue: 175.0/255.0,
                                             alpha: 0.5).cgColor

    }
}


