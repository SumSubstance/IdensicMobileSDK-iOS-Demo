//
//  SumSubAccount+Details.swift
//  IdensicMobileSDK-iOS-Demo
//
//  Created by Sergey Kokunov on 18.06.2020.
//  Copyright © 2020 Sum & Substance. All rights reserved.
//

import Foundation
import IdensicMobileSDK

extension SumSubAccount {
            
    static var isRegularIntegration: Bool {
        return SumSubEnvironment(rawValue: apiUrl) == .prod
    }

    static func getEnvironment() -> SNSEnvironment {
        return isRegularIntegration ? .production : SNSEnvironment(apiUrl)
    }
    
    static var isAuthorized: Bool { return hasBearerToken || hasAppToken }
    static var hasBearerToken: Bool { return YourBackend.bearerToken != nil }
    static var hasAppToken: Bool { return appToken != nil && !appToken!.isEmpty && secretKey != nil && !secretKey!.isEmpty }
    
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
        
        Storage.set(apiUrl, for: .apiUrl)
        Storage.set(isSandbox, for: .isSandbox)
        Storage.set(YourBackend.bearerToken, for: .bearerToken)
        Storage.set(YourBackend.client, for: .client)
    }
    
    static func restore() {
        
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
    
    private static let initialApiUrl = apiUrl
    private static let initialSandbox = isSandbox
    
    static func useAppToken() {
        
        apiUrl = initialApiUrl
        isSandbox = initialSandbox
        YourBackend.bearerToken = nil
        YourBackend.client = nil
        
        save()
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
