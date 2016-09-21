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
        
        enum Code : Int {
            case UnknownError = 4001
            case UnauthorizedError = 4002
        }
    }
}