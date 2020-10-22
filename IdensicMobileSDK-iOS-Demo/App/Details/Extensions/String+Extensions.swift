//
//  String+Extensions.swift
//  IdensicMobileSDK-iOS-Demo
//
//  Created by Sergey Kokunov on 16.06.2020.
//  Copyright © 2020 Sum & Substance. All rights reserved.
//

import Foundation

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
        
        return addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
    }
    
    static func random(len: Int) -> String {
        
        let chars = "abcdefghjklmnpqrstuvwxyz12345789"
        let random = (0..<len).compactMap { _ in chars.randomElement() }
        
        return String(random)
    }
}
