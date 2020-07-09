//
//  App.swift
//  IdensicMobileSDK-iOS-Demo
//
//  Created by Sergey Kokunov on 16.06.2020.
//  Copyright © 2020 Sum & Substance. All rights reserved.
//

import Foundation
import UIKit

struct App {
    
    static func start(with window: UIWindow) {
        
        SumSubAccount.restore()
        YourUser.restore()

        if SumSubAccount.isAuthorized {
            navigationController.setViewControllers([LoginVC.controller, DemoVC.controller], animated: true)
        }
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()        
    }
    
    static func showDemo() {
        
        navigationController.pushViewController(DemoVC.controller, animated: true)
    }
}

