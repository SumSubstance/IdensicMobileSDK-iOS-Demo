//
//  UIColor+Extensions.swift
//  IdensicMobileSDK-iOS-Demo
//
//  Created by Sergey Kokunov on 18.06.2020.
//  Copyright © 2020 Sum & Substance. All rights reserved.
//

import UIKit

extension UIColor {
    
    convenience init(_ hex: Int, alpha: CGFloat = 1.0) {
        
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0xFF00) >> 8) / 255.0
        let blue = CGFloat(hex & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    static var globalAlertBgColor: UIColor {
        return UIColor(0x222222)
    }
    
    static var bgColor: UIColor {
        return dynamicColor(0xFFFFFF, 0x222222)
    }

    static var toastBgColor: UIColor {
        return dynamicColor(0x222222, 0x444444)
    }

    static var navbarTintColor: UIColor {
        return textColor
    }
    
    static var actionTintColor: UIColor {
        return textColor
    }

    static var textColor: UIColor {
        return dynamicColor(0x41495B, 0xA2A3A2)
    }

    static var textFieldBorderColor: UIColor {
        return dynamicColor(0xaaaaaa, 0x4a4a4a)
    }
    
    static var textFieldFgColor: UIColor {
        return dynamicColor(0x4a4a4a, 0xA2A3A2)
    }

    static var textFieldBgColor: UIColor {
        return dynamicColor(0xF5F6F7, 0x323232)
    }

    static var actionFgColor: UIColor {
        return dynamicColor(0xFEFFFE, 0xe9e9e9)
    }

    static var actionBgColor: UIColor {
        return dynamicColor(0x173774, 0x006082)
    }

    static var alternativeBgColor: UIColor {
        return dynamicColor(0x1CB3A9, 0x008260)
    }

    private static func dynamicColor(_ lightColor: Int, _ darkColor: Int) -> UIColor {
        
        return dynamicColor(UIColor(lightColor), UIColor(darkColor))
    }
    
    private static func dynamicColor(_ lightColor: UIColor, _ darkColor: UIColor) -> UIColor {

        if #available(iOS 13.0, *) {
            return UIColor { (traitCollection) -> UIColor in
                return traitCollection.userInterfaceStyle == .dark ? darkColor : lightColor
            }
        } else {
            return lightColor
        }
    }
}
