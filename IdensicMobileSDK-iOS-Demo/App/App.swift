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
    
    static weak var window: UIWindow?
    
    static func start(with window: UIWindow) {
    
        self.window = window
        
        SumSubAccount.restore()
        YourUser.restore()

        if SumSubAccount.isAuthorized {
            showDemo()
        }
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()        
    }
    
    static func showDemo() {
        
        navigationController.setViewControllers([HomeVC.controller, DemoVC.controller], animated: true)
    }
}

