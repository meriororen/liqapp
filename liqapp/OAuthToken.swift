//
//  OAuthToken.swift
//  
//
//  Created by Isa Ansharullah on 9/21/16.
//
//

import Foundation
import LUKeychainAccess

extension Date {
    
    func dateByAdding(seconds: Int?) -> Date? {
        if seconds == nil {
            return nil
        }
        let calendar = Calendar.current
        var components = DateComponents()
        components.second = seconds!
        return (calendar as NSCalendar).date(byAdding: components, to: self, options: NSCalendar.Options())
    }
    
    func isLaterThan(_ aDate: Date) -> Bool {
        let isLater = self.compare(aDate) == ComparisonResult.orderedDescending
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
    
    var expires: Date
    var scope: String?
    
    required convenience init(coder decoder: NSCoder) {
        let expires : Date = {
            if let expiryDate =  decoder.decodeObject(forKey: Keys.expiresKey) as? Date {
                return expiryDate
            } else {
                return Date()
            }
        }()
        self.init(expiryDate: expires)
        self.scope = decoder.decodeObject(forKey: Keys.scopeKey) as! String!
        self.accessToken = decoder.decodeObject(forKey: Keys.accessTokenKey) as? String
    }
    
    init(expiryDate: Date) {
        self.expires = expiryDate
        super.init()
    }
    
    func setAllInstanceVariablesToNil() {
        self.accessToken = nil
    }
    
    fileprivate init?(accessToken: String?, expiresInSeconds: NSNumber) {
        if let expirationDate = Date().dateByAdding(seconds: expiresInSeconds.intValue) {
            self.expires = expirationDate
        } else {
            self.expires = Date()
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
            self.init(accessToken: anAccessToken, expiresInSeconds: NSNumber(expiresInSeconds))
        } else {
            self.init(expiryDate: Date())
            self.setAllInstanceVariablesToNil()
            return nil
        }
        
        storeInKeyChain()
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.accessToken, forKey: Keys.accessTokenKey)
        coder.encode(self.expires, forKey: Keys.expiresKey)
        coder.encode(self.scope, forKey: Keys.scopeKey)
    }
    
    func hasExpired() -> Bool {
        if accessToken == nil  {
            return true
        }
        let todayDate = Date()
        if expires.isLaterThan(todayDate) {
            return false
        }
        
        return true
    }
    
    class func oAuthTokenWithScope(_ scope: String) -> OAuthToken? {
        let dictionary = LUKeychainAccess.standard().object(forKey: Constants.kOAuth2TokensKey) as! NSDictionary?
        if let actualDictionary = dictionary as NSDictionary? {
            if let token = actualDictionary[scope] as?  OAuthToken? {
                return token
            }
        }
        return nil
    }
    
    class func oAuthTokens() -> Dictionary<String, AnyObject> {
        var tokenArray = Dictionary<String, AnyObject>()
        let dictionary = LUKeychainAccess.standard().object(forKey: Constants.kOAuth2TokensKey) as! NSDictionary?
        if let actualDictionary = dictionary {
            for key in actualDictionary.allKeys {
                if let actualKey = key as? String {
                    let object: AnyObject = actualDictionary[actualKey]! as AnyObject
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
            LUKeychainAccess.standard().setObject(existingTokens, forKey: Constants.kOAuth2TokensKey)
        }
    }
    
    func setExpiryDate(_ expiresInSeconds: NSNumber?) {
        if let actualExpirationDate = expiresInSeconds as NSNumber? {
            if let expirationDate = Date().dateByAdding(seconds: actualExpirationDate.intValue) {
                self.expires = expirationDate
                storeInKeyChain()
            }
        }
    }
    
    func removeFromKeychainIfNoAccessToken() {
        if accessToken == nil {
            var existingTokens = OAuthToken.oAuthTokens()
            existingTokens[scope!] = nil
            LUKeychainAccess.standard().setObject(existingTokens, forKey: Constants.kOAuth2TokensKey)
        }
    }
    
    func removeFromKeychainIfNotValid() {
        if accessToken == nil {
            removeFromKeychainIfNoAccessToken()
        }
    }
    
    class func removeAllTokens() {
        let emptyDic = Dictionary<String, AnyObject>()
        LUKeychainAccess.standard().setObject(emptyDic, forKey: Constants.kOAuth2TokensKey)
    }
    
}
