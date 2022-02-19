//
//  Storage+Details.swift
//  IdensicMobileSDK-iOS-Demo
//
//  Created by Sergey Kokunov on 19.06.2020.
//  Copyright © 2020 Sum & Substance. All rights reserved.
//

import Foundation

class Storage: UserDefaults {
    
    static var levelName: LevelName?
    static var flowName: FlowName?
    
    enum Key: String {
        case apiUrl
        case username
        case password
        case bearerToken
        case client
        case userId
        case flowName
        case levelName
        case externalActionId
        case lang
        case isSandbox
    }
    
    static func getString(_ key: Key) -> String? {
        return get(key) as? String
    }
    
    static func getBool(_ key: Key) -> Bool? {
        return get(key) as? Bool
    }

    static func get(_ key: Key) -> Any? {
        return standard.value(forKey: key.rawValue)
    }
    
    static func set(_ value: Any?, for key: Key) {
        standard.set(value, forKey: key.rawValue)
    }
}
