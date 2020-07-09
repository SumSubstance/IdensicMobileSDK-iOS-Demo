//
//  ToastManager+Extensions.swift
//  IdensicMobileSDK-iOS-Demo
//
//  Created by Sergey Kokunov on 19.06.2020.
//  Copyright © 2020 Sum & Substance. All rights reserved.
//

import Toast_Swift

extension ToastManager {
    
    static func setup() {
        
        ToastManager.shared.position = .top
        ToastManager.shared.duration = 5
        ToastManager.shared.style.maxWidthPercentage = 0.85
        ToastManager.shared.style.backgroundColor = .toastBgColor
        ToastManager.shared.style.titleFont = .systemFont(ofSize: 16, weight: .medium)
        ToastManager.shared.style.messageFont = .systemFont(ofSize: 16, weight: .light)
        ToastManager.shared.style.verticalPadding = 10
        ToastManager.shared.style.horizontalPadding = 16
    }
}
