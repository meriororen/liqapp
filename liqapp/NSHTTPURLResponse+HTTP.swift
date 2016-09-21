//
//  NSHTTPURLResponse+HTTP.swift
//  
//
//  Created by Isa Ansharullah on 9/21/16.
//
//

import Foundation

extension NSHTTPURLResponse {
    class func isUnauthorized(response: NSHTTPURLResponse?) -> Bool {
        if response == nil {
            return false
        }
        switch response!.statusCode {
        case 401:
            return true
        default:
            break
        }
        
        return false
    }
    
    func didSucceed() -> Bool {
        if 200...299 ~= statusCode {
            return true
        }
        return false
    }
    
    func didFail() -> Bool {
        if 300...599 ~= statusCode {
            return true
        }
        
        return false
    }
}
