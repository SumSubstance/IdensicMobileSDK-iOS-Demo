//
//  ScanVC.swift
//  IdensicMobileSDK-iOS-Demo
//
//  Created by Sergey Kokunov on 15.03.2021.
//  Copyright © 2021 Sum & Substance. All rights reserved.
//

extension ScanVC {
    
    func didScan(qrCode: QRCode) {
        
        logIntoSumSubAccount(with: qrCode, onSuccess: {
            
            App.showDemo()
        })
    }
}
