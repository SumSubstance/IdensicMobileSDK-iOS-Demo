//
//  TextField.swift
//  IdensicMobileSDK-iOS-Demo
//
//  Created by Sergey Kokunov on 21/05/2020.
//  Copyright © 2020 Sum & Substance. All rights reserved.
//

import UIKit

class TextField: UITextField {

    private struct Layout {
        static let insets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        static let closeButtonInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
        static let cornerRadius = CGFloat(8)
    }
    
    var value: String? {
        return hasValue ? text : nil;
    }
    
    var hasValue: Bool {
        return text != nil && text!.isEmpty == false
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .textFieldBgColor
        textColor = .textFieldFgColor
        
        if borderStyle == .line {
            layer.borderWidth = 0.5
            applyBorderColor()
        }

        borderStyle = .none
        clipsToBounds = true
        layer.cornerRadius = Layout.cornerRadius
    }

    private func applyBorderColor() {
        layer.borderColor = UIColor.textFieldBorderColor.cgColor
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return super.textRect(forBounds: bounds).inset(by: Layout.insets)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return super.editingRect(forBounds: bounds).inset(by: Layout.insets)
    }
    
    override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        return super.clearButtonRect(forBounds: bounds).inset(by: Layout.closeButtonInsets)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if layer.borderWidth > 0 {
            applyBorderColor()
        }
    }
}
