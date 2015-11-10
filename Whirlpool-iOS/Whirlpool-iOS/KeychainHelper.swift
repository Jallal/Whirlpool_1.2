
//
//  Created by CSE498 on 11/4/15.
//  Copyright © 2015 CSE498. All rights reserved.
//

import Foundation
import Security

class KeychainHelper
{
    static func set(key: String, value: String) -> Bool
    {
        if let data = value.dataUsingEncoding(NSUTF8StringEncoding)
        {
            return set(key, value: data)
        }
        
        return false
    }
    
    static func set(key: String, value: NSData) -> Bool
    {
        let query = [
            (kSecClass as String)       : kSecClassGenericPassword,
            (kSecAttrAccount as String) : key,
            (kSecValueData as String)   : value
        ]
        
        SecItemDelete(query as CFDictionaryRef)
        
        return SecItemAdd(query as CFDictionaryRef, nil) == noErr
    }
    
    static func get(key: String) -> NSString?
    {
        if let data = getData(key)
        {
            return NSString(data: data, encoding: NSUTF8StringEncoding)
        }
        
        return nil
    }
    
    static func getData(key: String) -> NSData?
    {
        let query = [
            (kSecClass as String)       : kSecClassGenericPassword,
            (kSecAttrAccount as String) : key,
            (kSecReturnData as String)  : kCFBooleanTrue,
            (kSecMatchLimit as String)  : kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        
        let status: OSStatus = withUnsafeMutablePointer(&dataTypeRef) { SecItemCopyMatching(query as CFDictionaryRef, UnsafeMutablePointer($0)) }
        
        if status == noErr {
            return dataTypeRef as? NSData
        }
        
        return nil
    }
    
    static func delete(key: String) -> Bool
    {
        let query = [
            (kSecClass as String)       : kSecClassGenericPassword,
            (kSecAttrAccount as String) : key
        ]
        
        return SecItemDelete(query as CFDictionaryRef) == noErr
    }
    
    static func clear() -> Bool
    {
        let query = [
            (kSecClass as String): kSecClassGenericPassword
        ]
        
        return SecItemDelete(query as CFDictionaryRef) == noErr
    }
}