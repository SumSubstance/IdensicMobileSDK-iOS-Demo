//
//  SumSubAccount.swift
//  IdensicMobileSDK-iOS-Demo
//
//  Created by Sergey Kokunov on 20/05/2020.
//  Copyright © 2020 Sum & Substance. All rights reserved.
//

import Foundation

struct SumSubAccount {
    //
    // If you'd like to run the demo on the simulator, you can use App Tokens authorization approach.
    // See https://developers.sumsub.com/api-reference/#app-tokens for details.
    //
    // Pay attention please that in your intergation all the sensitive things should be done on your backend.
    // For the demo purposes we have implemented the corresponding routines on the client side, but please,
    // in the real life use your backend and never store your credentials on the devices.
    //
    static var apiUrl: String = SumSubEnvironment.prod.apiUrl
    static var isSandbox: Bool = false
    static let appToken: String? = nil
    static let secretKey: String? = nil
}

enum SumSubEnvironment: String, Selectable {
    
    case prod = "https://api.sumsub.com"
    case sandbox = "sandbox"
}
