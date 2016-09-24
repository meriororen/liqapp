//
//  IbadahTableViewCell.swift
//  liqapp
//
//  Created by Isa Ansharullah on 9/24/16.
//  Copyright © 2016 DuldulStudio. All rights reserved.
//

import UIKit

class IbadahTableViewCell: UITableViewCell {

    @IBOutlet weak var ibadahLabel: UILabel!
    @IBOutlet weak var ibadahValue: UILabel!
    @IBOutlet weak var ibadahTarget: UILabel!
    @IBOutlet weak var ibadahIcon: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
