//
//  Mutabaah.swift
//  liqapp
//
//  Created by Isa Ansharullah on 9/28/16.
//  Copyright © 2016 DuldulStudio. All rights reserved.
//

import Foundation
import RealmSwift

class Mutabaah: Object {
    dynamic var date = ""
    dynamic var _id = ""
    dynamic var user_id = ""
    dynamic var group_id = ""
    var records = List<Record>()
    
    convenience init(id: String!) {
        self.init()
        self._id = id
    }

    override static func primaryKey() -> String? {
        return "_id"
    }
}

class Record: Object {
    dynamic var ibadah_id = ""
    dynamic var value = 0
    dynamic var mutabaah: Mutabaah? = nil
}

class Ibadah: Object {
    dynamic var id = ""
    dynamic var group_id = ""
    dynamic var name = ""
    dynamic var type = ""
    dynamic var target = ""
    dynamic var unit_name: String? = nil
}
