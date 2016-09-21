//
//  OAuthToken.swift
//  
//
//  Created by Isa Ansharullah on 9/21/16.
//
//

import Foundation
import LUKeychainAccess

extension NSDate {
    
    func dateByAdding(seconds seconds: Int?) -> NSDate? {
        if seconds == nil {
            return nil
        }
        let calendar = NSCalendar.currentCalendar()
        let components = NSDateComponents()
        components.second = seconds!
        return calendar.dateByAddingComponents(components, toDate: self, options: NSCalendarOptions())
    }
    
    func isLaterThan(aDate: NSDate) -> Bool {
        let isLater = self.compare(aDate) == NSComparisonResult.OrderedDescending
        return isLater
    }
}

class OAuthToken: NSObject {
    
    var refreshToken: String? {
        didSet {
            storeInKeyChain()
        }
    }
    
    var accessToken: String? {
        didSet {
            storeInKeyChain()
        }
    }
    
    var expires: NSDate
    var scope: String?
    
    init(expiryDate: NSDate) {
        self.expires = expiryDate
        super.init()
    }
    
    func hasExpired() -> Bool {
        if accessToken == nil  {
            return true
        }
        let todayDate = NSDate()
        if expires.isLaterThan(todayDate) {
            return false
        }
        
        return true
    }
    
    class func oAuthTokens() -> Dictionary<String, AnyObject> {
        var tokenArray = Dictionary<String, AnyObject>()
        let dictionary = LUKeychainAccess.standardKeychainAccess().objectForKey(Constants.kOAuth2TokensKey) as! NSDictionary?
        if let actualDictionary = dictionary {
            for key in actualDictionary.allKeys {
                if let actualKey = key as? String {
                    let object: AnyObject = actualDictionary[actualKey]!
                    tokenArray[actualKey] = object
                }
            }
        }
        
        return tokenArray
    }
    
    func storeInKeyChain() {
        let existingTokens = OAuthToken.oAuthTokens()
        LUKeychainAccess.standardKeychainAccess().setObject(existingTokens, forKey: Constants.kOAuth2TokensKey)
    }
    
    func setExpiryDate(expiresInSeconds: NSNumber?) {
        if let actualExpirationDate = expiresInSeconds as NSNumber? {
            if let expirationDate = NSDate().dateByAdding(seconds: actualExpirationDate.integerValue) {
                self.expires = expirationDate
                storeInKeyChain()
            }
        }
    }
    
}