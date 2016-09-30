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

print(Realm.Configuration.defaultConfiguration.fileURL!)

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

let jsondata = "[{\"name\" : \"Isa\", \"age\" : 23, \"bikes\" : [ { \"maker\" : \"Honda\", \"year\" : 1994 }] }, {\"name\" : \"hadi\", \"bikes\" : []}]".data(using: .utf8)

let data = try JSONSerialization.jsonObject(with: jsondata!, options: JSONSerialization.ReadingOptions.allowFragments) as! [[String:AnyObject]]


for d in data {
    do {
        try realm.write {
            let person = realm.create(Person.self, value: d)
        }
    } catch {
        print("wat")
    }
}

let results = realm.objects(Person.self)

for i in 0..<results.count {
    print(results[i].bikes)
}



