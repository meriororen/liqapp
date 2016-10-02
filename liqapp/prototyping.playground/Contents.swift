//: Playground - noun: a place where people can play

import UIKit
import RealmSwift

var str = "Hello, playground"
class Person: Object {
    dynamic var name = ""
    let age = RealmOptional<Int>()
    let bikes = List<Motorcycle>()
}

class Motorcycle: Object {
    dynamic var maker = ""
    dynamic var year = 0
    let owner: Person? = nil
}

let realm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "temp"))

//print(Realm.Configuration.defaultConfiguration.fileURL!)

let base = URL(string: "http://test.com/")
let full = URL(string: "test", relativeTo: base)
full?.absoluteString

/*
Realm.Configuration.defaultConfiguration = Realm.Configuration(
    schemaVersion: 1,
    migrationBLock: { (migration, oldVersion) in
        if (oldVersion < 1) {
            
        }
    }
)
*/

//let jsondata = "[{\"name\" : \"Isa\", \"age\" : 23, \"bikes\" : [ { \"maker\" : \"Honda\", \"year\" : 1994 }] }, {\"name\" : \"hadi\", \"bikes\" : [], \"age\": 25}]".data(using: .utf8)

let jsondata = "[{ \"maker\" : \"Honda\", \"year\" : 1994 }]".data(using: .utf8)

let data = try JSONSerialization.jsonObject(with: jsondata!, options: JSONSerialization.ReadingOptions.allowFragments) as! [[String:AnyObject]]


for d in data {
    do {
        try realm.write {
            let person = realm.create(Motorcycle.self, value: d)
        }
    } catch {
        print("wat")
    }
}

let result = realm.objects(Motorcycle.self).first { (bike) -> Bool in
    return bike.maker == "Honda"
}

let prop = result?.objectSchema.properties.map({ (p) -> String in
    return p.name
})

let dict = result?.dictionaryWithValues(forKeys: prop!) as! [String:AnyObject]

let blah = try! JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
print(dict)

let sblah = String(data: blah, encoding: String.Encoding.ascii)

print(sblah!)

/*
for (key, val) in dict! {
    print(key)
    if let v = val as? String {
        print(v)
    } else if let iv = val as? Int {
        print(iv)
    }
}


print(results.count)

for i in 0..<results.count {
    print(results[i].bikes)
}
*/



