//
//  Mutabaah.swift
//  liqapp
//
//  Created by Isa Ansharullah on 9/28/16.
//  Copyright © 2016 DuldulStudio. All rights reserved.
//

import Foundation

class Mutabaah: NSObject {
    var date: String!
    var id: String!
    var group_id: String!
    var user_id: String!
    var records = [Dictionary<String, AnyObject>]()
    
    override init() {
        super.init()
    }
    
    convenience init(id: String, date: String, user_id: String, group_id: String, records: [Dictionary<String, AnyObject>]) {
        self.init()
        
        self.id = id
        self.date = date
        self.user_id = user_id
        self.group_id = group_id
        self.records = records
    }
}
