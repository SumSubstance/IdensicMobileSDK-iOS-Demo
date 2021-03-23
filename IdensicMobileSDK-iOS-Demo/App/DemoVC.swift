//
//  DemoVC.swift
//  IdensicMobileSDK-iOS-Demo
//
//  Created by Sergey Kokunov on 21/05/2020.
//  Copyright © 2020 Sum & Substance. All rights reserved.
//

import UIKit

extension DemoVC {

    @IBAction func launchVerification(_ sender: Any) {
        
        IdentityVerification.launch(
            from: self,
            for: YourUser.current,
            flowName: YourUser.flowName,
            locale: Language.locale
        )
    }
}
