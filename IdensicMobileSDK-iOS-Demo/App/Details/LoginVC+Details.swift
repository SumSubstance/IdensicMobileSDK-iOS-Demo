//
//  LoginVC+Details.swift
//  IdensicMobileSDK-iOS-Demo
//
//  Created by Sergey Kokunov on 19.06.2020.
//  Copyright © 2020 Sum & Substance. All rights reserved.
//

import UIKit

extension LoginVC {
    
    static var controller: UIViewController { return App.storyboard.instantiateViewController(withIdentifier: "LoginVC") }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        view.backgroundColor = .bgColor
        
        usernameField.delegate = self
        passwordField.delegate = self
    }
    
    // MARK: - Environment
    
    func redrawEnvironment() {
        
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
    
    // MARK: -
    
    struct Layout {
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
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
