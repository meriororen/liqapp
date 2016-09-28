//
//  APIClient.swift
//  liqapp
//
//  Created by Isa Ansharullah on 9/21/16.
//  Copyright © 2016 DuldulStudio. All rights reserved.
//

import UIKit

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
        } else {
            // wat?
        }
    }
    
    func updateUserBasicInfo(then: @escaping () -> Void) {
        self.validateFullScope {
            /* fetch basic info */
            self.urlSessionJSONTask(url: "api/user", success: { (jsonData) in
                for (key, value) in jsonData {
                    if (key == "id" || key == "name" || key == "groups") {
                        self.rootResource.updateValue(value, forKey: key)
                    }
                }
                then()
                }, failure: { (error) in
                    print(error) /* TODO: error handling! */
            }).resume()
        }
    }
    
    func getUserMutabaahForDate(_ date: String, success: () -> Void, failure: (_ error: APIError) -> ()) {
        // not yet available
    }
    
    func getUserMutabaahs(then: @escaping () -> Void) {
        self.validateFullScope {
            /* fetch mutabaahs */
            self.urlSessionJSONTask(url: "api/user/mutabaahs", success: { (jsonData) in
                    if let anArray = jsonData["response"] as? [Dictionary<String, AnyObject>] {
                        var mutabaah = Dictionary<String, AnyObject>()
                        for data in anArray {
                            /*
                            let records = data["records"] as! Dictionary<String, String>
                            let m = Mutabaah(id: data["_id"]! as! String,
                                date: data["date"]! as! String,
                                user_id: data["user_id"]! as! String,
                                group_id: data["group_id"]! as! String,
                                records: records)
                            */
                            mutabaah.updateValue(data as AnyObject, forKey: data["date"] as! String)
                        }
                        self.rootResource.updateValue(mutabaah as AnyObject, forKey: "mutabaah")
                        then()
                    }
                }, failure: { (error) in
                    print(error) /* TODO: error handling! */
            }).resume()
        }
    }
    
    func fetchListOfIbadahs(then: @escaping () -> Void) {
        self.validateFullScope {
            if (self.listOfIbadahs.count > 0) { then() }
            /* fetch list of ibadahs */
            self.urlSessionJSONTask(url: "api/ibadahs", success: { (jsonData) in
                    /* clear all first */
                    self.listOfIbadahs.removeAllObjects()
                    if let anArray = jsonData["response"] as? [Dictionary<String, AnyObject>] {
                        for data in anArray {
                            self.listOfIbadahs.add(data)
                        }
                        then()
                    }
                }, failure: { (error) in
                    print(error) /* TODO: error handling! */
                }
            ).resume()
        }
    }
    
    func validateFullScope(then: @escaping () -> Void) {
        let fullToken = OAuthToken.oAuthTokenWithScope("fullscope")
        validate(oAuthToken: fullToken, validationSuccess: { (chosenToken) -> Void in
            self.updateAuthorizationHeader(chosenToken)
            then()
        },failure: nil)
    }
    
    func validate(oAuthToken: OAuthToken?, validationSuccess: (_ chosenToken: OAuthToken) -> Void, failure: ((_ error: NSError) -> Void)?) {
        if oAuthToken != nil {
            if oAuthToken!.hasExpired() == false {
                validationSuccess(oAuthToken!)
            } else {
                oAuthToken!.removeFromKeychainIfNotValid()
                // TODO: do another authentication here when user decided to remember username/password
                
                failure?(NSError(domain: Constants.Error.apiClientErrorDomain, code: Constants.Error.Code.unauthorizedError.rawValue, userInfo: nil))
            }
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
        if rootResource.count == 0 && listOfIbadahs.count == 0 {
            success()
            return
        }
        
        validateFullScope {
            self.rootResource.removeAll()
            self.listOfIbadahs.removeAllObjects()
            
            OAuthToken.removeAllTokens()
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
                        print("show login")
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
