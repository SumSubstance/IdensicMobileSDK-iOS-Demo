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

    static func makeNewUser(with level: ApplicantLevel) {
        
        current = YourUser(userId: "demo-user-" + String.random(len: 8))
        setLevel(level)
    }

    static func setLevel(_ level: ApplicantLevel) {
        
        current?.externalActionId = level.isAction ? "demo-action-" + String.random(len: 8) : nil
        Storage.levelName = level.name
        save()
    }

    static func save() {
        
        Storage.set(Storage.levelName, for: .levelName)
        Storage.set(Storage.flowName, for: .flowName)

        if let user = current {
            Storage.set(user.userId, for: .userId)
            Storage.set(user.externalActionId, for: .externalActionId)
        }
    }
    
    static func restore() {
        
        Storage.levelName = Storage.getString(.levelName)
        Storage.flowName = Storage.getString(.flowName)
        
        guard let userId = Storage.getString(.userId) else {
            return
        }
        
        current = YourUser(
            userId: userId,
            externalActionId: Storage.getString(.externalActionId)
        )
    }
}

// MARK: - Flow-based way

extension YourUser {
    
    static func makeNewUser(with flow: ApplicantFlow) {
        
        current = YourUser(userId: "demo-user-" + String.random(len: 8))
        setFlow(flow)
    }
    
    static func setFlow(_ flow: ApplicantFlow) {
        
        current?.externalActionId = flow.isAction ? "demo-action-" + String.random(len: 8) : nil
        Storage.flowName = flow.name
        Storage.levelName = nil
        save()
    }
}
