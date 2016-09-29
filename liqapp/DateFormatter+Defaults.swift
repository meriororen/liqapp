//
//  DateFormatter+Defaults.swift
//  liqapp
//
//  Created by Isa Ansharullah on 9/29/16.
//  Copyright © 2016 DuldulStudio. All rights reserved.
//

import Foundation


extension DateFormatter {
    func defaultDateFormatter() -> DateFormatter {
        self.dateFormat = "yyyy-MM-dd"
        return self
    }
    
    func readableDateFormatter() -> DateFormatter {
        self.dateFormat = "d MMMM yyyy"
        return self
    }
}
