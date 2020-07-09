//
//  LoginVC.swift
//  IdensicMobileSDK-iOS-Demo
//
//  Created by Sergey Kokunov on 18/05/2020.
//  Copyright © 2020 Sum & Substance. All rights reserved.
//

import UIKit

class LoginVC: UITableViewController {

    @IBOutlet weak var environmentField: DropdownField!
    @IBOutlet weak var usernameField: TextField!
    @IBOutlet weak var passwordField: TextField!
    @IBOutlet weak var loginButton: Button!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameField.text = SumSubAccount.username
        passwordField.text = SumSubAccount.password
        
        redrawEnvironment()
    }
    
    @IBAction func logIn(_ sender: Any) {
        
        hideKeyboard()
        
        guard let username = usernameField.value, let password = passwordField.value else {
            showAlert("Please, provide your credentials")
            return
        }
        
        SumSubAccount.username = username
        SumSubAccount.password = password
        
        loginButton.startActivity()
        
        YourBackend.logIntoSumSubAccount { [weak self] (error) in
            
            guard let self = self else { return }
            
            SumSubAccount.save()

            self.loginButton.stopActivity()

            if let error = error {
                self.showAlert(for: error)
            } else {
                App.showDemo()
            }
        }
    }    
}
