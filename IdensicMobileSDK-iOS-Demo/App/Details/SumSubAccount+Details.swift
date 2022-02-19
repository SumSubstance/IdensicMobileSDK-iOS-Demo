//
//  SumSubAccount+Details.swift
//  IdensicMobileSDK-iOS-Demo
//
//  Created by Sergey Kokunov on 18.06.2020.
//  Copyright © 2020 Sum & Substance. All rights reserved.
//

import Foundation

extension SumSubAccount {
            
    static let isFlowBased: Bool = {
        #if USE_FLOW_BASED_INITIALIZATION
        return true
        #else
        return false
        #endif
    }()

    static var isTestEnvironment: Bool { return SumSubEnvironment(rawValue: apiUrl) == .test }
    
    static var isAuthorized: Bool { return YourBackend.bearerToken != nil }
    static var hasCredentials: Bool { return !username.isEmpty || !password.isEmpty }
    
    static func linkTo(_ path: String) -> URL? {
        
        return URL(string: path, relativeTo: URL(string: apiUrl))
    }
    
    static func setEnvironment(_ environment: SumSubEnvironment) {
        
        apiUrl = environment.apiUrl
        isSandbox = environment.isSandbox
    }
    
    static var environmentName: String {
        
        if isSandbox {
            return SumSubEnvironment.sandbox.name
        } else {
            return SumSubEnvironment(rawValue: apiUrl)?.name ?? apiUrl
        }
    }
    
    static func save() {
        
        Storage.set(username, for: .username)
        Storage.set(password, for: .password)
        Storage.set(apiUrl, for: .apiUrl)
        Storage.set(isSandbox, for: .isSandbox)
        Storage.set(YourBackend.bearerToken, for: .bearerToken)
        Storage.set(YourBackend.client, for: .client)
    }
    
    static func restore() {
        
        if username.isEmpty, let username = Storage.getString(.username) {
            SumSubAccount.username = username
        }
        if password.isEmpty, let password = Storage.getString(.password) {
            SumSubAccount.password = password
        }
        if let apiUrl = Storage.getString(.apiUrl) {
            SumSubAccount.apiUrl = apiUrl
        }
        if let isSandbox = Storage.getBool(.isSandbox) {
            SumSubAccount.isSandbox = isSandbox
        }
        if let bearerToken = Storage.getString(.bearerToken) {
            YourBackend.bearerToken = bearerToken
        }
        if let client = Storage.getString(.client) {
            YourBackend.client = client
        }
    }
}

extension SumSubEnvironment {
    
    var isSandbox: Bool { self == .sandbox }
    
    var apiUrl: String {
        if isSandbox {
            return Self.prod.apiUrl
        } else {
            return rawValue
        }
    }
    
    var name: String {
        if isSandbox {
            return "sandbox"
        } else {
            return apiUrl.domain ?? apiUrl
        }
    }
}
