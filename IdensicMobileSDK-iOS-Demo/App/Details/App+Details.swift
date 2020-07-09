//
//  App+Details.swift
//  IdensicMobileSDK-iOS-Demo
//
//  Created by Sergey Kokunov on 20.06.2020.
//  Copyright © 2020 Sum & Substance. All rights reserved.
//

import UIKit
import Toast_Swift

extension App {
 
    static var storyboard = UIStoryboard(name: "Main", bundle: nil)
    static var navigationController = storyboard.instantiateInitialViewController() as! UINavigationController
    
    static func checkAutorizationStatus() {
        
        if !SumSubAccount.isAuthorized {
            SumSubAccount.save()
            navigationController.popToRootViewController(animated: true)
        }
    }
    
    // MARK: - Toast
    
    static var toastManager: ToastManager = {
        ToastManager.setup()
        
        return ToastManager.shared
    }()
    
    static func showToast(_ message: String?) {
        
        guard let message = message, let canvas = UIApplication.shared.keyWindow else {
            return
        }
        
        var style = toastManager.style
        style.verticalPadding = 16
        
        let toast = try! canvas.toastViewForMessage(
            message,
            title: nil,
            image: nil,
            style: style
        )
        
        canvas.hideAllToasts()
        canvas.showToast(toast)
    }
    
    // MARK: - Alert
    
    static func showAlert(_ message: String) {
        
        topVC?.showAlert(message)
    }
    
    static var topVC: UIViewController? {
        
        func findTopVC(from topVC: UIViewController?) -> UIViewController? {
            
            var topVC = topVC
            
            if let vc = topVC?.presentedViewController, type(of: vc) != UIAlertController.self {
                topVC = findTopVC(from: vc)
            }
            
            if let navVC = topVC as? UINavigationController {
                topVC = findTopVC(from: navVC.topViewController)
            }
            
            return topVC;
        }
        
        return findTopVC(from: UIApplication.shared.keyWindow?.rootViewController)
    }

}
