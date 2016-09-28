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
        return self.capitalized
    }
    
    func separateAndCapitalize(_ separator: String) -> String {
        var strs: [String] = self.components(separatedBy: separator)
        strs = strs.map { (str) -> String in
            str.capitalize()
        }
        return strs.joined(separator: " ")
    }
    
    func separate(_ separator: String) -> String {
        let strs: [String] = self.components(separatedBy: separator)
        return strs.joined(separator: " ")
    }
}
