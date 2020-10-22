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

    static func makeNewUser(with flow: Flow) {
        
        current = YourUser(userId: "demo-user-" + String.random(len: 8))
        setFlow(flow)
    }

    static func setFlow(_ flow: Flow) {
        
        current?.flowName = flow.name
        current?.externalActionId = flow.isAction ? "demo-action-" + String.random(len: 8) : nil
        
        save()
    }

    static func save() {
        
        if let user = current {
            Storage.set(user.userId, for: .userId)
            Storage.set(user.flowName, for: .flowName)
            Storage.set(user.externalActionId, for: .externalActionId)
        }
    }
    
    static func restore() {
        
        guard let userId = Storage.getString(.userId) else {
            return
        }
        
        current = YourUser(
            userId: userId,
            flowName: Storage.getString(.flowName),
            externalActionId: Storage.getString(.externalActionId)
        )
    }
}
