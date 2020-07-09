//
//  SumSubAccount.swift
//  IdensicMobileSDK-iOS-Demo
//
//  Created by Sergey Kokunov on 20/05/2020.
//  Copyright © 2020 Sum & Substance. All rights reserved.
//

import Foundation

struct SumSubAccount {
    
    static var apiUrl: String = SumSubEnvironment.test.apiUrl
    static var username: String = ""
    static var password: String = ""
}

enum SumSubEnvironment: String, Selectable {
    
    case test = "https://test-api.sumsub.com"
    case prod = "https://api.sumsub.com"
}
