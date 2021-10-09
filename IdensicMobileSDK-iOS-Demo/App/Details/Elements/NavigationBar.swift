//
//  NavigationBar.swift
//  IdensicMobileSDK-iOS-Demo
//
//  Created by Sergey Kokunov on 18/05/2020.
//  Copyright © 2020 Sum & Substance. All rights reserved.
//

import UIKit

class NavigationBar: UINavigationBar {

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        barTintColor = .bgColor
        tintColor = .navbarTintColor
        
        titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.textColor]
        
        if #available(iOS 15.0, *) {
            
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            
            appearance.backgroundColor = barTintColor
            appearance.shadowImage = UIImage()
            appearance.shadowColor = .clear
            if let titleTextAttributes = titleTextAttributes {
                appearance.titleTextAttributes = titleTextAttributes
            }
            
            standardAppearance = appearance
            scrollEdgeAppearance = standardAppearance
            
        } else {
            
            shadowImage = UIImage()
            setValue(NSNumber(booleanLiteral: true), forKeyPath: "hidesShadow")
        }

    }
}
