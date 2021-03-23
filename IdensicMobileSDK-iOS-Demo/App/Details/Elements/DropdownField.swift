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

    private lazy var activityIndicator = UIActivityIndicatorView(style: .white)
    private lazy var dropdownImageView = UIImageView(image: UIImage(named: "dropdown"))

    override func awakeFromNib() {
        super.awakeFromNib()

        activityIndicator.color = textColor

        rightView = dropdownImageView
        rightViewMode = .always
        delegate = self
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        return super.rightViewRect(forBounds: bounds).inset(by: Layout.rightRectInsets)
    }
    
    internal func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }
    
    override var isEnabled: Bool {
        didSet {
            rightView?.alpha = isEnabled ? 1 : 0.35
        }
    }
    
    // MARK: -
    
    private var isBusy = false
    
    func startActivity() {
        
        redraw(isBusy: true)
    }
    
    func stopActivity() {
        redraw(isBusy: false)
    }
    
    private func redraw(isBusy: Bool) {
        
        if self.isBusy == isBusy {
            return
        }
        
        self.isBusy = isBusy
        
        if isBusy {
            if rightView != activityIndicator {
                rightView = activityIndicator
            }
            activityIndicator.startAnimating()
        } else {
            if rightView != dropdownImageView {
                rightView = dropdownImageView
            }
            activityIndicator.stopAnimating()
        }
                
        isUserInteractionEnabled = !isBusy
    }

}
