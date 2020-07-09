//
//  DropdownField.swift
//  IdensicMobileSDK-iOS-Demo
//
//  Created by Sergey Kokunov on 21/05/2020.
//  Copyright © 2020 Sum & Substance. All rights reserved.
//

import UIKit

class DropdownField: TextField, UITextFieldDelegate {
    
    struct Layout {
        static let rightRectInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 16)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
                
        rightView = UIImageView(image: UIImage(named: "dropdown"))
        rightViewMode = .always
        delegate = self
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        return super.rightViewRect(forBounds: bounds).inset(by: Layout.rightRectInsets)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }
    
    override var isEnabled: Bool {
        didSet {
            rightView?.alpha = isEnabled ? 1 : 0.35
        }
    }
}
