//
//  APIClient.swift
//  liqapp
//
//  Created by Isa Ansharullah on 9/21/16.
//  Copyright © 2016 DuldulStudio. All rights reserved.
//

import UIKit

class APIClient: NSObject, NSURLSessionDelegate {
    
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
    
    var session: NSURLSession!
    var additionalHeaders = Dictionary<String, String>()
    var lastPerformedTask: NSURLSessionTask? = nil
    var listOfIbadahs: NSMutableArray = NSMutableArray()
    var rootResource = Dictionary<String, AnyObject>()
    
    override init() {
        super.init()
        
        self.additionalHeaders[Constants.HTTPHeaderKeys.contentType] = Constants.HTTPHeaderValues.urlencoded
        
        let sessionConfiguration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        sessionConfiguration.requestCachePolicy = NSURLRequestCachePolicy.ReturnCacheDataElseLoad
        
        let theSession = NSURLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
        self.session = theSession
    }
    
    func updateAuthorizationHeader(token: OAuthToken?) {
        if let actualToken = token as OAuthToken! {
            self.additionalHeaders["Authorization"] = actualToken.accessToken
        } else {
            // wat?
        }
    }
    
    func updateUserBasicInfo(then then: () -> Void) {
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
    
    func getUserMutabaahForDate(date: String, success: () -> Void, failure: (error: APIError) -> ()) {
        // not yet available
    }
    
    func getUserMutabaahs(then then: () -> Void) {
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
                            mutabaah.updateValue(data, forKey: data["date"] as! String)
                        }
                        self.rootResource.updateValue(mutabaah, forKey: "mutabaah")
                        then()
                    }
                }, failure: { (error) in
                    print(error) /* TODO: error handling! */
            }).resume()
        }
    }
    
    func fetchListOfIbadahs(then then: () -> Void) {
        self.validateFullScope {
            if (self.listOfIbadahs.count > 0) { then() }
            /* fetch list of ibadahs */
            self.urlSessionJSONTask(url: "api/ibadahs", success: { (jsonData) in
                    /* clear all first */
                    self.listOfIbadahs.removeAllObjects()
                    if let anArray = jsonData["response"] as? [Dictionary<String, AnyObject>] {
                        for data in anArray {
                            self.listOfIbadahs.addObject(data)
                        }
                        then()
                    }
                }, failure: { (error) in
                    print(error) /* TODO: error handling! */
                }
            ).resume()
        }
    }
    
    func validateFullScope(then then: () -> Void) {
        let fullToken = OAuthToken.oAuthTokenWithScope("fullscope")
        validate(oAuthToken: fullToken, validationSuccess: { (chosenToken) -> Void in
            self.updateAuthorizationHeader(chosenToken)
            then()
        },failure: nil)
    }
    
    func validate(oAuthToken oAuthToken: OAuthToken?, validationSuccess: (chosenToken: OAuthToken) -> Void, failure: ((error: NSError) -> Void)?) {
        if oAuthToken != nil {
            if oAuthToken!.hasExpired() == false {
                validationSuccess(chosenToken: oAuthToken!)
            } else {
                oAuthToken!.removeFromKeychainIfNotValid()
                // TODO: do another authentication here when user decided to remember username/password
                
                failure?(error: NSError(domain: Constants.Error.apiClientErrorDomain, code: Constants.Error.Code.UnauthorizedError.rawValue, userInfo: nil))
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
    
    private func logout(success success: () -> Void, failure: (error: APIError) -> ()) {
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
    
    private func cancelTasks(tasks: [AnyObject]) {
        for object in tasks {
            if let task = object as? NSURLSessionTask {
                task.cancel()
            }
        }
    }
    
    func cancelAllRunningTasks (then then: () -> Void) {
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
                    dispatch_async(dispatch_get_main_queue(), {
                        print("show login")
                        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                        appdelegate.startApplicationFromAuth()
                    })
                }, failure: { (error) in
                    // TODO: proper error handling
                    print("cannot logout")
            })
        }
    }
}
