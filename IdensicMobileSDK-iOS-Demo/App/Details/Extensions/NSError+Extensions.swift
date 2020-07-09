//
//  NSError+Extensions.swift
//  IdensicMobileSDK-iOS-Demo
//
//  Created by Sergey Kokunov on 21/05/2020.
//  Copyright © 2020 Sum & Substance. All rights reserved.
//

import Foundation

extension NSError {
    
    convenience init(_ message: String?) {
        
        self.init(domain: "demoErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: message ?? "Unknown error"])
    }
}
