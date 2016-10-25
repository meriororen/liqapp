//
//  AuthManager.swift
//  
//
//  Created by Isa Ansharullah on 9/22/16.
//
//

import Foundation
import AFNetworking

class AuthManager: NSObject {
    static let sharedManager = AuthManager()
    
    var sessionManager: AFHTTPSessionManager!
    
    override init() {
        super.init()
        
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
        
        let _sessionManager = AFHTTPSessionManager(baseURL: Constants.url.baseURL as URL?, sessionConfiguration: configuration)
        
        _sessionManager.requestSerializer = AFHTTPRequestSerializer()
        
        _sessionManager.responseSerializer = AFHTTPResponseSerializer()
        
        self.sessionManager = _sessionManager
    }
    
    func authenticateWithCode(_ parameters: Dictionary<String, AnyObject>, success: @escaping () -> Void, failure: @escaping (_ error: APIError) -> ()) {
        self.sessionManager.post((Constants.url.authURL?.absoluteString)!, parameters: parameters, progress: nil, success: { (task, response) in
                if let actualHeader = (task.response as! HTTPURLResponse!).allHeaderFields as? Dictionary<String, AnyObject> {
                    let oAuthToken = OAuthToken(attributes: actualHeader)
                    if (oAuthToken != nil) {
                        success()
                    } else {
                        failure(APIError(domain: Constants.Error.authManagerErrorDomain, code: Constants.Error.Code.unknownError.rawValue, userInfo: nil))
                    }
                }
            }, failure: { (task, error) in
                if let response = task?.response as? HTTPURLResponse {
                    if response.didFail() {
                        failure(APIError(domain: Constants.Error.authManagerErrorDomain, code: Constants.Error.Code.unauthorizedError.rawValue, userInfo: nil))
                    }
                } else {
                    failure(APIError(domain: Constants.Error.authManagerErrorDomain, code: Constants.Error.Code.unknownError.rawValue, userInfo: nil))
                }
        })
    }
    

}
