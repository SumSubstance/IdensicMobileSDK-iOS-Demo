//
//  YourUser+Details.swift
//  IdensicMobileSDK-iOS-Demo
//
//  Created by Sergey Kokunov on 18.06.2020.
//  Copyright © 2020 Sum & Substance. All rights reserved.
//

import Foundation

extension YourUser {
    
    static var current: YourUser?
    
    static var hasCurrent: Bool { return current != nil }
    
    static var userId: String? { return current?.userId}
    static var flowName: String { return current?.flowName ?? "msdk-basic-kyc"}

    static func makeNewUser(with flowName: FlowName) {
        
        current = YourUser(
            userId: "demo-user-" + String.random(len: 8),
            flowName: flowName
        )
        save()
    }
    
    static func save() {
        
        if let user = current {
            Storage.set(user.userId, for: .userId)
            Storage.set(user.flowName, for: .flowName)
        }
    }
    
    static func restore() {
        
        guard let userId = Storage.getString(.userId) else {
            return
        }
        
        current = YourUser(
            userId: userId,
            flowName: Storage.getString(.flowName)
        )
    }
}
