//
//  User.swift
//  liqapp
//
//  Created by Isa Ansharullah on 10/22/16.
//  Copyright © 2016 DuldulStudio. All rights reserved.
//

import UIKit
import RealmSwift

class User: Object {
    dynamic var _id = ""
    dynamic var name = ""
    dynamic var defaultGroup: String? = nil
    
    override static func primaryKey() -> String? {
        return "_id"
    }
}
