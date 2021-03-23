//
//  LoginVC+Details.swift
//  IdensicMobileSDK-iOS-Demo
//
//  Created by Sergey Kokunov on 19.06.2020.
//  Copyright © 2020 Sum & Substance. All rights reserved.
//

import UIKit

class LoginVC: UITableViewController {
    
    static var controller: UIViewController { return App.storyboard.instantiateViewController(withIdentifier: "LoginVC") }
        
    @IBOutlet weak var environmentField: DropdownField!
    @IBOutlet weak var usernameField: TextField!
    @IBOutlet weak var passwordField: TextField!
    @IBOutlet weak var loginButton: Button!
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        view.backgroundColor = .bgColor
        
        usernameField.delegate = self
        passwordField.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameField.text = SumSubAccount.username
        passwordField.text = SumSubAccount.password
        
        redrawEnvironment()
    }
    
    // MARK: - Actions
    
    func logIntoSumSubAccount(onSuccess: @escaping () -> Void) {
        
        hideKeyboard()
        
        guard usernameField.hasValue == passwordField.hasValue else {
            showWarning()
            return
        }
        
        SumSubAccount.username = usernameField.value ?? ""
        SumSubAccount.password = passwordField.value ?? ""
        
        loginButton.startActivity()
        
        YourBackend.logIntoSumSubAccount { [weak self] (error, isAuthorized) in
            
            guard let self = self else { return }
            
            SumSubAccount.save()
            
            self.loginButton.stopActivity()
            
            if let error = error {
                self.showAlert(for: error)
            } else if !isAuthorized {
                self.showWarning()
            } else {
                onSuccess()
            }
        }
    }
    
    private func showWarning() {
        
        if !usernameField.hasValue || !passwordField.hasValue {
            showAlert("Please, provide your credentials")
        } else {
            showAlert("Login failed")
        }
    }
    

    // MARK: - Environment
    
    private func redrawEnvironment() {
        
        environmentField.text = SumSubAccount.environmentName
    }
    
    @IBAction func selectEnvironment(_ sender: Any) {
        
        showSelect(from: sender, SumSubEnvironment.self, "Select Environment") { (environment) in
            
            if let environment = environment {
                SumSubAccount.setEnvironment(environment)
                self.redrawEnvironment()
            }
        }
    }

    // MARK: - UITableViewDelegate
    
    private struct Layout {
        static let firstRowHeight = CGFloat(238)
        static let initialHeight = CGFloat(568)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row != 0 {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
        
        var availableHeight: CGFloat = 0
        if #available(iOS 11.0, *) {
            availableHeight = tableView.safeAreaLayoutGuide.layoutFrame.height
        } else {
            availableHeight = tableView.frame.height
        }
        
        return Layout.firstRowHeight + availableHeight - Layout.initialHeight
    }
}

extension LoginVC: UITextFieldDelegate {
    
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        switch textField {
        case usernameField:
            passwordField.becomeFirstResponder()
            
        case passwordField:
            logIn(passwordField!)
            
        default:
            break
        }
        
        return true
    }
}
