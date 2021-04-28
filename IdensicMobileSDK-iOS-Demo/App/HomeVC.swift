//
//  HomeVC.swift
//  IdensicMobileSDK-iOS-Demo
//
//  Created by Sergey Kokunov on 17.03.2021.
//  Copyright © 2021 Sum & Substance. All rights reserved.
//

import UIKit

extension HomeVC {
    
    @IBAction func scanQRcode(_ sender: Any) {
        
        push(ScanVC.controller)
    }
    
    @IBAction func signIn(_ sender: Any) {
        
        push(LoginVC.controller)
    }
}
