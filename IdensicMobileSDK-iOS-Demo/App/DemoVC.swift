//
//  DemoVC.swift
//  IdensicMobileSDK-iOS-Demo
//
//  Created by Sergey Kokunov on 21/05/2020.
//  Copyright © 2020 Sum & Substance. All rights reserved.
//

import UIKit

extension DemoVC {

    func launchVerification() {
        
        IdentityVerification.launch(
            from: self,
            for: YourUser.current,
            locale: Language.locale
        )
    }
}
