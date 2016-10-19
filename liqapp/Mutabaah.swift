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
            if let groupids = APIClient.sharedClient.rootResource["groups"] as? [String] {
                return groupids.count > 0 ? groupids[0] : ""
            } else {
                return ""
            }
        }()
    }

    override static func primaryKey() -> String? {
        return "date"
    }
    
    func toDictionary() -> Dictionary<String, AnyObject> {
        let properties = self.objectSchema.properties.map { (p) -> String in return p.name }
        var mutabledic = Dictionary<String, AnyObject>()
        for prop in properties as [String] {
            
            if prop == "_id" { continue }
            
            if let stringVal = self[prop] as? String {
                mutabledic.updateValue(stringVal as AnyObject, forKey: prop)
            } else if let recordList = self[prop] as? List<Record> {
                var records = [Dictionary<String, AnyObject>]()
                for rec in recordList {
                    let recVal = rec.toDictionary()
                    records.append(recVal)
                }
                mutabledic.updateValue(records as AnyObject, forKey: prop)
            }
        }
        
        return mutabledic
    }
}

