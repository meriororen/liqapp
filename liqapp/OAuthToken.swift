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

private struct Keys {
    static let accessTokenKey = "accesstoken"
    static let scopeKey = "scope"
    static let expiresKey = "expires"
}

class OAuthToken: NSObject, NSCoding {
    
    var accessToken: String? {
        didSet {
            storeInKeyChain()
        }
    }
    
    var expires: NSDate
    var scope: String?
    
    required convenience init(coder decoder: NSCoder) {
        let expires : NSDate = {
            if let expiryDate =  decoder.decodeObjectForKey(Keys.expiresKey) as? NSDate {
                return expiryDate
            } else {
                return NSDate()
            }
        }()
        self.init(expiryDate: expires)
        self.scope = decoder.decodeObjectForKey(Keys.scopeKey) as! String!
        self.accessToken = decoder.decodeObjectForKey(Keys.accessTokenKey) as? String
    }
    
    init(expiryDate: NSDate) {
        self.expires = expiryDate
        super.init()
    }
    
    func setAllInstanceVariablesToNil() {
        self.accessToken = nil
    }
    
    private init?(accessToken: String?, expiresInSeconds: NSNumber) {
        if let expirationDate = NSDate().dateByAdding(seconds: expiresInSeconds.integerValue) {
            self.expires = expirationDate
        } else {
            self.expires = NSDate()
            super.init()
            self.setAllInstanceVariablesToNil()
            return nil
        }
        
        if let actualAccessToken = accessToken as String? {
            self.accessToken = actualAccessToken
        }
        
        self.scope = "fullscope"
        super.init()
        storeInKeyChain()
    }
    
    convenience init?(attributes: Dictionary<String, AnyObject>) {
        let anAccessToken = attributes["Authorization"] as! String
        let expiresIn: String = attributes["Expires_in"] as! String
        
        if let expiresInSeconds = Int(expiresIn) {
            self.init(accessToken: anAccessToken, expiresInSeconds: expiresInSeconds)
        } else {
            self.init(expiryDate: NSDate())
            self.setAllInstanceVariablesToNil()
            return nil
        }
        
        storeInKeyChain()
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.accessToken, forKey: Keys.accessTokenKey)
        coder.encodeObject(self.expires, forKey: Keys.expiresKey)
        coder.encodeObject(self.scope, forKey: Keys.scopeKey)
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
        
        //print((tokenArray["fullscope"] as! OAuthToken).hasExpired())
        
        return tokenArray
    }
    
    func storeInKeyChain() {
        var existingTokens = OAuthToken.oAuthTokens()
        if let actualScope = scope {
            existingTokens[actualScope] = self
            LUKeychainAccess.standardKeychainAccess().setObject(existingTokens, forKey: Constants.kOAuth2TokensKey)
        }
    }
    
    func setExpiryDate(expiresInSeconds: NSNumber?) {
        if let actualExpirationDate = expiresInSeconds as NSNumber? {
            if let expirationDate = NSDate().dateByAdding(seconds: actualExpirationDate.integerValue) {
                self.expires = expirationDate
                storeInKeyChain()
            }
        }
    }
    
    class func removeAllTokens() {
        let emptyDic = Dictionary<String, AnyObject>()
        LUKeychainAccess.standardKeychainAccess().setObject(emptyDic, forKey: Constants.kOAuth2TokensKey)
    }
    
}