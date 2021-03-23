//
//  SumSubAccount+Details.swift
//  IdensicMobileSDK-iOS-Demo
//
//  Created by Sergey Kokunov on 18.06.2020.
//  Copyright © 2020 Sum & Substance. All rights reserved.
//

import Foundation

extension SumSubAccount {
        
    static var isAuthorized: Bool { return YourBackend.bearerToken != nil }
    static var hasCredentials: Bool { return !username.isEmpty || !password.isEmpty }
    
    static func linkTo(_ path: String) -> URL? {
        
        return URL(string: path, relativeTo: URL(string: apiUrl))
    }
    
    static func setEnvironment(_ environment: SumSubEnvironment) {
        
        apiUrl = environment.apiUrl
    }
    
    static var environmentName: String {
        
        return SumSubEnvironment(rawValue: apiUrl)?.name ?? apiUrl
    }
    
    static func save() {
        
        Storage.set(username, for: .username)
        Storage.set(password, for: .password)
        Storage.set(apiUrl, for: .apiUrl)
        Storage.set(YourBackend.bearerToken, for: .bearerToken)
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
        if let bearerToken = Storage.getString(.bearerToken) {
            YourBackend.bearerToken = bearerToken
        }
    }
}

extension SumSubEnvironment {
    
    var apiUrl: String { rawValue }
    var name: String { apiUrl.domain ?? apiUrl }
}
