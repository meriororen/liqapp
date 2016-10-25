//
//  ItemButton.swift
//  liqapp
//
//  Created by Isa Ansharullah on 10/19/16.
//  Copyright © 2016 DuldulStudio. All rights reserved.
//

import UIKit
import FontAwesome_swift

class ItemButton: UIButton {
    @IBOutlet weak var FAIconLabel: UILabel!
    @IBOutlet weak var ItemLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        nibSetup()
    }
    
    override var isEnabled: Bool {
        set(new) {
            super.isEnabled = new
            if (new == false) {
                self.FAIconLabel.textColor = UIColor.lightGray
                self.ItemLabel.textColor = UIColor.lightGray
                self.FAIconLabel.isUserInteractionEnabled = false
                self.ItemLabel.isUserInteractionEnabled = false
            }
        }
        get {
            return super.isEnabled
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        nibSetup()
    }
    
    private func nibSetup() {
        let view = loadViewFromNib()
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.translatesAutoresizingMaskIntoConstraints = true
        view.isUserInteractionEnabled = false
        
        FAIconLabel.font = UIFont.fontAwesomeOfSize(30.0)
        ItemLabel.font = UIFont.fontAwesomeOfSize(15.0)
        
        addSubview(view)
    }
    
    private func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "ItemButton", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0]
        
        return view as! UIView
    }
}

