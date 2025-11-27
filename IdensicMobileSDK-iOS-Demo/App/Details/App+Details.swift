//
//  App+Details.swift
//  IdensicMobileSDK-iOS-Demo
//
//  Created by Sergey Kokunov on 20.06.2020.
//  Copyright © 2020 Sum & Substance. All rights reserved.
//

import UIKit
import Toast_Swift
import AVFoundation
import CoreHaptics

extension App {
 
    static var storyboard = UIStoryboard(name: "Main", bundle: nil)
    static var navigationController = initialNavigationController
    static var initialNavigationController: UINavigationController {
        return storyboard.instantiateInitialViewController() as! UINavigationController
    }
    
    // MARK: - Authorization Control
    
    @discardableResult
    static func checkAutorizationStatus() -> Bool {
        
        if SumSubAccount.isAuthorized { return true }
        
        SumSubAccount.save()

        App.showGlobalAlert("Your session has expired, please log into your Sumsub account once again") { alertWindow in
            
            hideGlobalAlert(alertWindow) {
                
                guard let window = window else { return }
                
                if let sdk = IdentityVerification.sdk {
                    sdk.setOnDidDismiss(nil) // supress the possible toasts on sdk dismiss
                    
                    if let presentedVC = sdk.mainVC.presentedViewController {
                        presentedVC.dismiss(animated: false, completion: nil)
                    }
                }
                
                navigationController = initialNavigationController
                window.rootViewController = navigationController
            }
        }
        
        return false
    }
    
    // MARK: - Toast
    
    static var toastManager: ToastManager = {
        ToastManager.setup()
        
        return ToastManager.shared
    }()
    
    static func showToast(_ message: String?) {
        
        guard let message = message, let canvas = window else {
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
    
    // MARK: - Global Alerts
    
    private static let globalAlertBgAlpha = CGFloat(0.9)
    
    static func showGlobalAlert(_ message: String, actionHandler: ((UIWindow) -> Void)? = nil) {
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        if #available(iOS 13.0, *) {
            alertWindow.windowScene = self.window?.windowScene
        }
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        alertWindow.tintColor = self.window?.tintColor
        alertWindow.rootViewController = UIViewController()

        alertWindow.backgroundColor = UIColor.globalAlertBgColor.withAlphaComponent(globalAlertBgAlpha)
        alertWindow.alpha = 0

        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.showAlert(message) {
            actionHandler?(alertWindow)
        }

        UIView.animate(withDuration: 0.25) {
            alertWindow.alpha = 1
        }
    }
    
    static func hideGlobalAlert(_ alertWindow: UIWindow, inTheMiddle: (() -> Void)? = nil) {
        
        alertWindow.backgroundColor = .globalAlertBgColor
        alertWindow.alpha = globalAlertBgAlpha
        
        UIView.animate(withDuration: 0.35) {
            
            alertWindow.alpha = 1
            
        } completion: { _ in
            
            inTheMiddle?()
            
            UIView.animate(withDuration: 0.35) {
                alertWindow.alpha = 0
            } completion: { _ in
                _ = alertWindow
            }
        }
    }
    
    // MARK: - Alerts

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
        
        return findTopVC(from: window?.rootViewController)
    }

    // MARK: - Sounds
    
    static func playVibrate() {
        
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    static func playSuccess() {
        if #available(iOS 13.0, *) {
            playFeedbackNotification(.success)
        } else {
            playVibrate()
        }
    }
    
    static func playWarning() {
        if #available(iOS 13.0, *) {
            playFeedbackNotification(.warning)
        } else {
            playVibrate()
        }
    }

    // MARK: - Haptics
    
    @available(iOS 13.0, *)
    static let feedbackGenerator = UINotificationFeedbackGenerator()

    @available(iOS 13.0, *)
    static func playFeedbackNotification(_ feedbacktype: UINotificationFeedbackGenerator.FeedbackType) {
        
        if CHHapticEngine.capabilitiesForHardware().supportsHaptics {
            feedbackGenerator.notificationOccurred(feedbacktype)
        } else {
            playVibrate()
        }
    }
    
}
