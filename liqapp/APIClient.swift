//
//  APIClient.swift
//  liqapp
//
//  Created by Isa Ansharullah on 9/21/16.
//  Copyright © 2016 DuldulStudio. All rights reserved.
//

import UIKit
import RealmSwift

class APIClient: NSObject, URLSessionDelegate {
    
    class var sharedClient: APIClient {
        struct Singleton {
            static let sharedClient = APIClient()
        }
        
        return Singleton.sharedClient
    }
    
    enum httpMethod: String {
        case post = "POST"
        case delete = "DELETE"
        case update = "UPDATE"
        case put = "PUT"
        case get = "GET"
    }
    
    var session: URLSession!
    var additionalHeaders = Dictionary<String, String>()
    var lastPerformedTask: URLSessionTask? = nil
    var listOfIbadahs: NSMutableArray = NSMutableArray()
    var rootResource = Dictionary<String, AnyObject>()
    var realm: Realm!
    var realmConfig: Realm.Configuration!
    
    override init() {
        super.init()
        
        self.additionalHeaders[Constants.HTTPHeaderKeys.contentType] = Constants.HTTPHeaderValues.urlencoded
        
        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.requestCachePolicy = NSURLRequest.CachePolicy.returnCacheDataElseLoad
        
        let theSession = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
        
        self.session = theSession
    }
    
    func updateAuthorizationHeader(_ token: OAuthToken?) {
        if let actualToken = token as OAuthToken! {
            self.additionalHeaders["Authorization"] = actualToken.accessToken
        }
    }
    
    func updateRealmDB() {
        /* realm config */
        var config = Realm.Configuration()
        
        let userid = APIClient.sharedClient.rootResource["id"] as! String
        config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("\(userid).realm")
        
        //print(config.fileURL)
        
        self.realmConfig = config
        self.realm = try! Realm(configuration: self.realmConfig)
    }
    
    func updateUserBasicInfo(then: @escaping () -> Void) {
        self.validateFullScope {
            /* fetch basic info */
            self.urlSessionJSONTaskSerialized(url: "api/user", success: { (jsonData) in
                for (key, value) in jsonData {
                    if (key == "id" || key == "name" || key == "groups") {
                        self.rootResource.updateValue(value, forKey: key)
                    }
                }
                
                /* first time opening realm is after we get the user id*/
                self.updateRealmDB()
                
                then()
                }, failure: { (error) in
                    print(error) /* TODO: error handling! */
            }).resume()
        }
    }
    
    func registerUser(_ userInfo: Dictionary<String,AnyObject>, success: @escaping () -> Void, failure: @escaping (_ error: APIError) -> ())
    {
        self.urlSessionPostJSONTaskWithNoAuthorizationHeader(APIClient.httpMethod.post, url: "api/users", parameters: userInfo, success: {
                print("success registering user")
                success()
            }, failure: { (error:APIError) in
                failure(error)
        }).resume()
    }
    
    func getGroupForId(_ groupId: String, success: @escaping (Dictionary<String,AnyObject>) -> Void, failure: @escaping (_ error: APIError) -> ()) {
        self.urlSessionJSONTaskSerialized(url: "api/groups/\(groupId)", success: { (jsonData) in
                success(jsonData)
            }, failure: { (error:APIError) in
                failure(error)
        }).resume()
    }
    
    func getUserMutabaahForDate(_ date: String, success: () -> Void, failure: (_ error: APIError) -> ()) {
        // not yet available
    }
    
    func getUserMutabaahs(then: @escaping () -> Void) {
        self.validateFullScope {
            /* fetch mutabaahs */
            self.urlSessionJSONTaskSerialized(url: "api/user/mutabaahs", success: { (jsonData) in
                if let anArray = jsonData["response"] as? [Dictionary<String, AnyObject>] {
                        /* manage as realm objects */
                        for data in anArray {
                            let mutabaah = self.realm.object(ofType: Mutabaah.self, forPrimaryKey: data["date"])
                            /* only update when no such mutabaah, or its id is empty */
                            //print(data["date"] as! String)
                            if ( mutabaah == nil ) {
                                do {
                                    try self.realm.write {
                                        let m = self.realm.create(Mutabaah.self, value: data, update: true)
                                        for r in m.records {
                                            r.mutabaah = m._id!
                                        }
                                    }
                                } catch {
                                    // TODO: error handling
                                    print("realm error!")
                                }
                            } else if (mutabaah?._id == nil) {
                                let newrecords = data["records"] as! [[String:AnyObject]]
                                do {
                                    try self.realm.write {
                                        mutabaah?._id = data["_id"] as? String
                                        for r in (mutabaah?.records)! {
                                            r.mutabaah = data["_id"] as? String
                                            r.value = { () -> Int in
                                                for n in newrecords {
                                                    if n["ibadah_id"] as! String == r.ibadah_id {
                                                        return n["value"] as! Int
                                                    }
                                                }
                                                return 0
                                            }()
                                        }
                                    }
                                } catch {
                                    // TODO: error handling
                                    print("realm error!")
                                }
                            }
                        }
                        then()
                    }
                }, failure: { (error) in
                    print(error) /* TODO: error handling! */
            }).resume()
        }
    }
    
    func postMutabaah(mutabaah: Mutabaah, success: @escaping () -> Void, failure: @escaping (_ error: APIError) -> Void) {
        //print(mutabaah.toDictionary())
        self.validateFullScope {
            if mutabaah._id == nil || mutabaah._id == "" {
                self.urlSessionPostJSONTask(httpMethod.post, url: "api/mutabaahs", parameters: mutabaah.toDictionary(), success: {
                        success()
                    }, failure: { (error) in
                        //print("cannot post mutabaah!")
                        failure(error)
                }).resume()
            } else {
                self.urlSessionPostJSONTask(httpMethod.put, url: "api/mutabaahs/\(mutabaah._id!)", parameters: mutabaah.toDictionary(), success: success, failure: { (error) in
                        print("cannot update mutabaah!")
                        failure(error)
                }).resume()
            }
        }
    }
    
    func getListOfIbadahs(then: @escaping () -> Void) {
        self.validateFullScope {
            if (self.listOfIbadahs.count > 0) { then() }
            /* fetch list of ibadahs */
            self.urlSessionJSONTaskSerialized(url: "api/ibadahs", success: { (jsonData) in
                    if let anArray = jsonData["response"] as? [Dictionary<String, AnyObject>] {
                        for data in anArray {
                            let id = data["_id"] as! String
                            let existing = self.realm.object(ofType: Ibadah.self, forPrimaryKey: id)
                            print(existing?._id)
                            if existing == nil || existing?._id == "" {
                                do {
                                    try self.realm.write {
                                        self.realm.create(Ibadah.self, value: data, update: true)
                                    }
                                } catch {
                                    // TODO : error handling!
                                    print("cannot create realm ibadah")
                                }
                            }
                        }
                        then()
                    }
                }, failure: { (error) in
                    print(error) /* TODO: error handling! */
                }
            ).resume()
        }
    }
    
    func getAllGroups(_ success: @escaping (_ arrayData:[Dictionary<String,AnyObject>]) -> Void, failure: @escaping (_ error:APIError) -> ()) {
        self.validateFullScope {
            self.urlSessionJSONTaskSerialized(url: "api/groups", success: { (jsonData) in
                    if let arrayData = jsonData["response"] as? [Dictionary<String,AnyObject>] {
                        success(arrayData)
                    }
                }, failure: { (error) in
                    failure(error)
            }).resume()
            }
    }
    
    func getGroupInformation(_ success: @escaping (_ groupInfo:Dictionary<String,AnyObject>) -> Void, failure: @escaping (_ error:APIError) -> ()) {
        self.validateFullScope {
            self.validateUserGroup(success: { 
                    let groupid = (self.rootResource["groups"] as! [String])[0]
                    self.urlSessionJSONTaskSerialized(url: "api/groups/\(groupid)", success: { (jsonData) in
                        success(jsonData)
                    }, failure: { (error) in
                        // reauth?
                        // TODO: what should we do when failed fetching groups?
                    }).resume()
                }, failure: { (error) in
                    failure(error)
                    print("error validating user/group info")
            })
        }
    }
    
    func requestJoinGroup(_ groupid: String!, success: @escaping () -> Void, failure: @escaping (_ error:APIError) -> ()) {
        self.validateFullScope {
            let memberParam = ["user_id" : self.rootResource["id"]! as AnyObject,
                               "group_id" : groupid as AnyObject]
            
            //print(memberParam)
            
            self.urlSessionPostJSONTask(.post, url: "api/members", parameters: memberParam, success: {
                    success()
                }, failure: { (error:APIError) in
                    print("cannot join group!")
                    failure(error)
            }).resume()
        }
    }
    
    // MARK - Detail

    func validateUserGroup(success: @escaping () -> Void, failure: @escaping (_ error:APIError) -> Void) {
        if ((self.rootResource["id"] as? String) != nil) {
            if let groups = self.rootResource["groups"] as? [String] {
                if groups.count > 0 {
                    success()
                } else {
                    // no group yet
                    failure(APIError(domain: Constants.Error.apiClientErrorDomain, code: Constants.Error.Code.userGroupNotExistError.rawValue, userInfo: nil))
                }
            }
        } else {
            // no user info yet
            print("no user info yet")
            failure(APIError(domain: Constants.Error.apiClientErrorDomain, code: Constants.Error.Code.userInfoError.rawValue, userInfo: nil))
        }
    }
    
    func validateFullScope(then: @escaping () -> Void) {
        let fullToken = OAuthToken.oAuthTokenWithScope("fullscope")
        validate(oAuthToken: fullToken, validationSuccess: { (chosenToken) -> Void in
            self.updateAuthorizationHeader(chosenToken)
            then()
            }, failure: { (error: NSError) -> Void in
                // TODO: error handling!
                print("cannot validate")
                self.logoutThenDeleteAllStoredData()
        })
    }
    
    func validate(oAuthToken: OAuthToken?, validationSuccess: (_ chosenToken: OAuthToken) -> Void, failure: ((_ error: NSError) -> Void)?) {
        if oAuthToken != nil {
            if oAuthToken!.hasExpired() == false {
                /* validate info and group */
                //if let groups = self.rootResource["groups"] as? [String] {
                //}
                
                validationSuccess(oAuthToken!)
            } else {
                oAuthToken!.removeFromKeychainIfNotValid()
                // TODO: do another authentication here when user decided to remember username/password
                
                failure?(NSError(domain: Constants.Error.apiClientErrorDomain, code: Constants.Error.Code.unauthorizedError.rawValue, userInfo: nil))
            }
        } else {
            // TODO: error handling
            print("oAuthToken is nil!")
        }
    }
    
    func isSessionInvalid() -> Bool {
        let allTokens = OAuthToken.oAuthTokens()
        if allTokens.count != 0 {
            for (_, token) in allTokens {
                if token is OAuthToken {
                    if (token.hasExpired() == false) {
                        return false
                    }
                }
            }
        }
        
        return true
    }
    
    fileprivate func logout(success: @escaping () -> Void, failure: (_ error: APIError) -> ()) {
        if OAuthToken.oAuthTokens().count > 0{
            validateFullScope {
                self.rootResource.removeAll()
                self.listOfIbadahs.removeAllObjects()
                
                OAuthToken.removeAllTokens()
                success()
            }
        } else {
            success()
        }
    }
    
    fileprivate func cancelTasks(_ tasks: [AnyObject]) {
        for object in tasks {
            if let task = object as? URLSessionTask {
                task.cancel()
            }
        }
    }
    
    func cancelAllRunningTasks (then: () -> Void) {
        self.session.getTasksWithCompletionHandler { ( dataTasks, uploadTasks, downloadTasks) in
            self.cancelTasks(dataTasks)
            self.cancelTasks(uploadTasks)
            self.cancelTasks(downloadTasks)
        }
        print("cancel tasks")
        then()
    }
    
    func logoutThenDeleteAllStoredData() {
        self.cancelAllRunningTasks {
            self.logout(success: { 
                    DispatchQueue.main.async(execute: {
                        let appdelegate = UIApplication.shared.delegate as! AppDelegate
                        appdelegate.startApplicationFromAuth()
                    })
                }, failure: { (error) in
                    // TODO: proper error handling
                    print("cannot logout")
            })
        }
    }
}
