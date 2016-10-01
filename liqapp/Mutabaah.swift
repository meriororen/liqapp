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
    dynamic var _id: String? = nil
    dynamic var user_id = ""
    dynamic var group_id = ""
    var records = List<Record>()
    
    convenience init(id: String!) {
        self.init()
        self._id = id
    }
    
    convenience init(date: String!) {
        self.init()
        self.date = date
        self.user_id = {
            if let user_id = APIClient.sharedClient.rootResource["id"] as? String {
                return user_id
            } else {
                return ""
            }
        }()
        self.group_id = {
            if let group_id = APIClient.sharedClient.rootResource["groups"] as? [String] {
                return group_id[0]
            } else {
                return ""
            }
        }()
    }

    override static func primaryKey() -> String? {
        return "date"
    }
}

class Record: Object {
    dynamic var ibadah_id = ""
    dynamic var value = 0
    //dynamic var mutabaah: Mutabaah? = nil
    //let mutabaah = LinkingObjects(fromType: Mutabaah.self, property: "records")
    dynamic var mutabaah: String?
    
    convenience init(mutabaah: String!) {
        self.init()
        self.mutabaah = mutabaah
    }
    
    convenience init(id: String, value: Int) {
        self.init()
        self.ibadah_id = id
        self.value = value
    }
}

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
