//
//  AlertController.swift
//  IdensicMobileSDK-iOS-Demo
//
//  Created by Sergey Kokunov on 18.06.2020.
//  Copyright © 2020 Sum & Substance. All rights reserved.
//

import UIKit

class AlertController: UIAlertController {

    convenience init(style: Style = .alert, title: String? = "", message: String? = nil) {
        self.init(title: title, message: message, preferredStyle: style)
    }
    
    func addCancelAction(_ title: String = "Cancel", handler: (() -> Void)? = nil) {
        addAction(title, .cancel, handler: handler)
    }
    
    func addAction(_ title: String?, _ style: UIAlertAction.Style = .default, handler: (() -> Void)? = nil) {
        addAction(UIAlertAction(title: title, style: style) { (action) in
            handler?()
        })
    }
    
    func present(from vc: UIViewController, animated: Bool = true) {
        vc.present(self, animated: animated, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.tintColor = .actionTintColor
        
        // A kinda hack to suppress "Unable to simultaneously satisfy constraints" when the controller is presented
        for subView in view.subviews {
            for constraint in subView.constraints where constraint.debugDescription.contains("width == - 16") {
                subView.removeConstraint(constraint)
            }
        }
    }
}
