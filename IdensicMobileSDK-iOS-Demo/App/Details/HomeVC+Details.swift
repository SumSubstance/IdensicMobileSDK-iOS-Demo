//
//  HomeVC+Details.swift
//  IdensicMobileSDK-iOS-Demo
//
//  Created by Sergey Kokunov on 17.03.2021.
//  Copyright © 2021 Sum & Substance. All rights reserved.
//

import UIKit

class HomeVC: UIViewController {
    
    static var controller: UIViewController { return App.storyboard.instantiateViewController(withIdentifier: "HomeVC") }

    @IBOutlet weak var appTokenButton: SecondaryButton!
    @IBOutlet weak var appTokenButtonHeight: NSLayoutConstraint!
    
    // MARK: - Lifecycle
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        navigationItem.backBarButtonItem?.title = "Login"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .bgColor
        
        if !SumSubAccount.hasAppToken {
            appTokenButton.alpha = 0
            appTokenButtonHeight.constant = 8
        }
    }
    
    // MARK: - Actions
    
    func push(_ vc: UIViewController) {
        
        navigationItem.backBarButtonItem?.title = " "
        navigationController?.pushViewController(vc, animated: true)
    }
}
