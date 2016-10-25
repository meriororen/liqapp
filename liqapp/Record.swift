//
//  Record.swift
//  liqapp
//
//  Created by Isa Ansharullah on 10/15/16.
//  Copyright © 2016 DuldulStudio. All rights reserved.
//

import UIKit
import RealmSwift

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
    
    func toDictionary() -> Dictionary<String, AnyObject> {
        let properties = self.objectSchema.properties.map { (p) -> String in return p.name }
        var mutabledic = Dictionary<String, AnyObject>()
        for prop in properties as [String] {
            
            if prop == "mutabaah" { continue }
            
            if let val = self[prop] {
                mutabledic.updateValue(val as AnyObject, forKey: prop)
            }
        }
        
        return mutabledic
    }
}
