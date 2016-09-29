//
//  Constants.swift
//  
//
//  Created by Isa Ansharullah on 9/21/16.
//
//

import Foundation

struct Constants {
    
    static let kOAuth2TokensKey = "OAuth2TokensKey"
    
    struct HTTPHeaderKeys {
        static let contentType = "Content-Type"
    }
    
    struct HTTPHeaderValues {
        static let urlencoded = "application/x-www-form-urlencoded"
    }
    
    struct Error {
        static let apiClientErrorDomain = "APIClientErrorDomain"
        static let authManagerErrorDomain = "AUTHManErrorDomain"
        
        enum Code : Int {
            case unknownError = 4001
            case unauthorizedError = 4002
        }
    }
    
    
    struct url {
        static let baseURL = URL(string: "http://liqo.herokuapp.com/")
        //static let baseURL = NSURL(string: "http://localhost:3000/")
        static let authURL = URL(string: "api/auth", relativeTo: baseURL)
    }
}
