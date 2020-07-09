//
//  Language+Details.swift
//  IdensicMobileSDK-iOS-Demo
//
//  Created by Sergey Kokunov on 19.06.2020.
//  Copyright © 2020 Sum & Substance. All rights reserved.
//

import Foundation

extension Language {
    
    static var locale: String { current.identifier }
    
    static func setCurrent(_ lang: Language) {
        Storage.set(lang.rawValue, for: .lang)
    }
    
    static var current: Language {
        if let rawValue = Storage.getString(.lang) {
            return Language(rawValue: rawValue) ?? .system
        } else {
            return .system
        }
    }
    
    var identifier: String {
        if self == .system {
            return Locale.current.identifier
        } else {
            return rawValue
        }
    }
    
    var name: String {
        if self == .system {
            return "System Language"
        } else {
            return Locale(identifier: identifier).localizedString(forLanguageCode: rawValue)?.capitalized ?? rawValue
        }
    }
}
