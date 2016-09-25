//
//  String+Capitalize.swift
//  liqapp
//
//  Created by Isa Ansharullah on 9/25/16.
//  Copyright © 2016 DuldulStudio. All rights reserved.
//

import Foundation

extension String {
    func capitalize() -> String {
        return self.capitalizedString
    }
    
    func separateAndCapitalize(separator: String) -> String {
        var strs: [String] = self.componentsSeparatedByString(separator)
        strs = strs.map { (str) -> String in
            str.capitalize()
        }
        return strs.joinWithSeparator(" ")
    }
    
    func separate(separator: String) -> String {
        let strs: [String] = self.componentsSeparatedByString(separator)
        return strs.joinWithSeparator(" ")
    }
}