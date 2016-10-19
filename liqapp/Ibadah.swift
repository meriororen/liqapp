//
//  Ibadah.swift
//  liqapp
//
//  Created by Isa Ansharullah on 10/15/16.
//  Copyright © 2016 DuldulStudio. All rights reserved.
//

import UIKit
import RealmSwift

class Ibadah: Object {
    dynamic var _id = ""
    dynamic var group_id = ""
    dynamic var name = ""
    dynamic var type = ""
    dynamic var target = ""
    dynamic var unit_name: String? = nil
    
    override static func primaryKey() -> String? {
        return "_id"
    }
}
