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
    
    func updateUserResources(then then: () -> Void) {
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
                    } else {
                        for (_, value) in jsonData {
                            self.listOfIbadahs.addObject(value)
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
        }
    }
    
    func cancelAllRunningTasks () {
        
    }
    
    
    func logoutThenDeleteAllStoredData() {
    
    }
}
