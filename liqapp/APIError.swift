//
//  APIError.swift
//  
//
//  Created by Isa Ansharullah on 9/21/16.
//
//

import Foundation

struct APIErrorConstants {
    static let errorCode = "error-code"
    static let noErrorCode = -9999
}

class APIError: NSError {
    var responseText: String?
    var urlResponse: HTTPURLResponse!
    var httpStatusCode : Int = 0
    var jsonResponse: Dictionary<String, AnyObject>!
    
    convenience init(error: NSError) {
        self.init(error: error)
    }
    
    init(urlResponse: HTTPURLResponse, jsonResponse: Dictionary<String, AnyObject>) {
        responseText = jsonResponse.description
        httpStatusCode = urlResponse.statusCode
        super.init(domain: Constants.Error.apiClientErrorDomain, code: Constants.Error.Code.unknownError.rawValue, userInfo: nil)
    }
    
    override init(domain: String, code: Int, userInfo dict: [AnyHashable: Any]?) {
        super.init(domain: domain, code: code, userInfo: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
