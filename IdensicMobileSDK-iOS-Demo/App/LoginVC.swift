//
//  LoginVC.swift
//  IdensicMobileSDK-iOS-Demo
//
//  Created by Sergey Kokunov on 18/05/2020.
//  Copyright © 2020 Sum & Substance. All rights reserved.
//

import UIKit

extension LoginVC {

    @IBAction func logIn(_ sender: Any) {
        
        logIntoSumSubAccount(onSuccess: {
            
            App.showDemo()
        })
    }
}
