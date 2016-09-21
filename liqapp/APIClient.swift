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
    var isSessionValid: Bool! = false
    var lastPerformedTask: NSURLSessionTask? = nil
    
    override init() {
        super.init()
        
        self.additionalHeaders[Constants.HTTPHeaderKeys.contentType] = Constants.HTTPHeaderValues.urlencoded
        
        let sessionConfiguration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        sessionConfiguration.requestCachePolicy = NSURLRequestCachePolicy.ReturnCacheDataElseLoad
        
        let theSession = NSURLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
        self.session = theSession
    }
    
    func updateAuthorizationHeader(accessToken: String) {
        self.additionalHeaders["Authorization"] = accessToken
    }
    
    func fetchListOfIbadahs() -> NSArray {
        let result = NSMutableArray()
        
        return result as NSArray
    }
    
    func validate(oAuthToken oAuthToken: OAuthToken?, validationSuccess: (chosenToken: OAuthToken) -> Void, failure: ((error: NSError) -> Void)?) {
        if oAuthToken?.hasExpired() == false {
            validationSuccess(chosenToken: oAuthToken!)
            return
        } else {
            failure?(error: NSError(domain: Constants.Error.apiClientErrorDomain, code: Constants.Error.Code.UnauthorizedError.rawValue, userInfo: nil))
        }
    }
}
