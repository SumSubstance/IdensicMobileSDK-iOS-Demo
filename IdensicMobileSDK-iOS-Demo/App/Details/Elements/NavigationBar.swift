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
        
        shadowImage = UIImage()
        setValue(NSNumber(booleanLiteral: true), forKeyPath: "hidesShadow")
        
        titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.textColor]
    }
}
