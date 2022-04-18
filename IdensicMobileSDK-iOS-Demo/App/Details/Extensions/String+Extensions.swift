//
//  String+Extensions.swift
//  IdensicMobileSDK-iOS-Demo
//
//  Created by Sergey Kokunov on 16.06.2020.
//  Copyright © 2020 Sum & Substance. All rights reserved.
//

import Foundation
import CommonCrypto

extension String {
    
    var trim: String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var isEmpty: Bool {
        return trim.lengthOfBytes(using: .utf8) <= 0
    }

    var domain: String? {
        
        return URL(string: self)?.host
    }
    
    var urlQueryEncoded: String {
        
        return addingPercentEncoding(withAllowedCharacters: .percentEncondingSet) ?? self
    }
    
    func hmac256(key: String) -> String {
        
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), key, key.count, self, self.count, &digest)
        
        return Data(digest).map({ String(format: "%02hhx", $0) }).joined()
    }
    
    static func random(len: Int) -> String {
        
        let chars = "abcdefghjklmnpqrstuvwxyz12345789"
        let random = (0..<len).compactMap { _ in chars.randomElement() }
        
        return String(random)
    }
}

extension CharacterSet {
    
    fileprivate static var percentEncondingSet: CharacterSet = {
        
        var set = CharacterSet.urlQueryAllowed
        set.remove(charactersIn: "/+")
        return set
    }()
}
