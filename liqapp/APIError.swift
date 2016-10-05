//
//  APIError.swift
//  
//
//  Created by Isa Ansharullah on 9/21/16.
//
//

import UIKit

struct APIErrorConstants {
    static let errorCode = "error-code"
    static let noErrorCode = -9999
}

class APIError: NSError {
    var responseText: String?
    var urlResponse: HTTPURLResponse!
    var httpStatusCode : Int = 0
    var jsonResponse: Dictionary<String, AnyObject>!
    
    var alert: UIAlertController? {
        get {
            return displayAlert()
        }
    }
    
    init(error: NSError) {
        super.init(domain: error.domain, code: error.code, userInfo: error.userInfo)
    }
    
    init(urlResponse: HTTPURLResponse, jsonResponse: Dictionary<String, AnyObject>) {
        responseText = jsonResponse.description
        httpStatusCode = urlResponse.statusCode
        super.init(domain: Constants.Error.apiClientErrorDomain, code: Constants.Error.Code.unknownError.rawValue, userInfo: nil)
    }
    
    init(urlResponse: HTTPURLResponse, response: String) {
        responseText = response
        super.init(domain: Constants.Error.apiClientErrorDomain, code: Constants.Error.Code.unknownError.rawValue, userInfo: nil)
    }
    
    override init(domain: String, code: Int, userInfo dict: [AnyHashable: Any]?) {
        super.init(domain: domain, code: code, userInfo: nil)
    }
    
    func displayAlert(_ message: String? = nil) -> UIAlertController {
        let title = { () -> String in
            switch(self.domain) {
            case Constants.Error.apiClientErrorDomain: return "API Error : \(self.code)"
            default: return "Error!"
            }
        }()
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if let message = message {
            alert.message = message
        } else {
            alert.message = self.responseText
        }
        
        let ok = UIAlertAction(title: "OK", style: .default)
        alert.addAction(ok)
        
        return alert
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
