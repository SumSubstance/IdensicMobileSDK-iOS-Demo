//
//  IdentityVerification.swift
//  IdensicMobileSDK-iOS-Demo
//
//  Created by Sergey Kokunov on 15/05/2020.
//  Copyright © 2020 Sum & Substance. All rights reserved.
//

import Foundation
import IdensicMobileSDK

struct IdentityVerification {
        
    private static var sdk: SNSMobileSDK!
        
    static func launch(
        from yourVC: UIViewController,
        for user: YourUser?,
        flowName: String,
        accessToken: String = "",
        locale: String? = nil)
    {

        // Notes:
        //
        // 1. In order to identify an applicant to be verifed you create and pass down an `accessToken`
        //    that is bound to your user. The access token has limited lifespan and when it's expired you must
        //    provide another one. In order to do so you will ask your backend and most likely the backend
        //    will need to know the user's identifier. This is the only reason we have passed down `YourUser` here.
        //    It's used within `tokenExpirationHandler` in order to communicate to `YourBackend`.
        //
        // 2. The `flowName` designates the applicant flow that must be set up with the dashboard (SDK Integrations -> Verification Flows).
        //
        // 3. You can either provide the `accessToken` right at the initializaton stage,
        //    or pass it as an empty string initially and supply it later on with `tokenExpirationHandler`.
        //    The second way allows you not to worry about spinners and so on. We'll go this way below.
        //
        // 4. The `locale` parameter can be nil or any string in a form of "en" or "en_US".
        //    In the case of nil, the system locale will be used automatically.
        
        log("Initialization")
        
        sdk = SNSMobileSDK(
            baseUrl: SumSubAccount.apiUrl,
            flowName: flowName,
            accessToken: accessToken,
            locale: locale,
            supportEmail: "support@your-company.com" // or use `nil` and configure Support Items later on
        )
        
        guard sdk.isReady else {
            logAndAlert("Initialization failed: " + sdk.verboseStatus)
            return
        }
        
        // If `accessToken` was empty during initialization, the sdk will call `tokenExpirationHandler` right after it's appeared up.
        // The same handler will be called when the access token is invalid or expired.
        
        sdk.tokenExpirationHandler { (onComplete) in
            
            YourBackend.getAccessToken(for: user) { (error, newToken) in
                
                if let error = error {
                    log("Failed to get new access token from the backend: \(error.localizedDescription)")
                }
                
                onComplete(newToken)
            }
        }
        
        // Advanced setup (it's optional and could be skipped)
        
        setupLogging()
        setupHandlers()
        setupCallbacks()
        setupSupportItems()
        setupTheme()
        
        log("Launch")

        // Present UI
        
        yourVC.present(sdk.mainVC, animated: true, completion: nil)
    }
    
    private static func setupLogging() {
        
        #if DEBUG
        
        // Change `logLevel` to see more info in the console (the default level is `.error`)
        sdk.logLevel = .error
        
        // By default SDK uses `NSLog` for the logging purposes. If it does not work, you could use `logHandler` to overcome.
        sdk.logHandler { (level, message) in
            print(Date.formatted, "[Idensic] \(message)")
        }
        
        #else
        
        // Perhaps it's good idea to shut the logs down in production
        sdk.logLevel = .off
        
        #endif
    }
    
    private static func setupHandlers() {
        
        // Fired when verification process is done with a final decision
        sdk.verificationHandler { (isApproved) in
            log("verificationHandler: Applicant is " + (isApproved ? "approved" : "finally rejected"))
        }
        
        // If `dismissHandler` is assigned, it's up to you to dismiss the `mainVC` controller.
        sdk.dismissHandler { (sdk, mainVC) in
            mainVC.dismiss(animated: true, completion: nil)
        }
    }
        
    private static func setupCallbacks() {
        
        // Fired when the sdk's status has been updated
        
        sdk.onStatusDidChange { (sdk, prevStatus) in
                        
            let prevStatusDesc = sdk.description(for: prevStatus)
            let lastStatusDesc = sdk.description(for: sdk.status)
            let failReasonDesc = sdk.description(for: sdk.failReason)

            let description: String
            
            switch sdk.status {
            case .ready:
                description = "Ready to be presented"
                
            case .failed:
                description = "failReason: [\(failReasonDesc)] \(sdk.verboseStatus)"
                
            case .initial:
                description = "No verification steps are passed yet"
                
            case .incomplete:
                description = "Some but not all of the verification steps have been passed over"
                
            case .pending:
                description = "Verification is pending"
                
            case .temporarilyDeclined:
                description = "Applicant has been declined temporarily"
                
            case .finallyRejected:
                description = "Applicant has been finally rejected"
                
            case .approved:
                description = "Applicant has been approved"
            }
            
            log("onStatusDidChange: [\(prevStatusDesc)] -> [\(lastStatusDesc)] \(description)")
        }
        
        // A way to be notified when `mainVC` is dismissed
        
        sdk.onDidDismiss { (sdk) in

            let lastStatusDesc = sdk.description(for: sdk.status)
            let failReasonDesc = sdk.description(for: sdk.failReason)
            
            let description: String
            
            if sdk.isFailed {
                description = "[\(lastStatusDesc):\(failReasonDesc)] \(sdk.verboseStatus)"
            } else {
                description = "[\(lastStatusDesc)]"
            }
            
            log("onDidDismiss: status \(description)")
            
            App.showToast("Identity verification status is \(description)")
        }
    }
    
    private static func setupSupportItems() {
        
        // Add Support Items if required
        
        sdk.addSupportItem { (item) in
            item.title = NSLocalizedString("URL Item", comment: "")
            item.subtitle = NSLocalizedString("Tap me to open an url", comment: "")
            item.icon = UIImage(named: "AppIcon")
            item.actionURL = URL(string: "https://google.com")
        }
        
        sdk.addSupportItem { (item) in
            item.title = NSLocalizedString("Callback Item", comment: "")
            item.subtitle = NSLocalizedString("Tap me to get callback fired", comment: "")
            item.icon = UIImage(named: "AppIcon")
            item.actionHandler { (supportVC, item) in
                logAndAlert("[\(item.title)] tapped")
            }
        }
    }
    
    private static func setupTheme() {
        
        // You could either adjust UI in place
        sdk.theme.sns_CameraScreenTorchButtonTintColor = .white
        
        // or apply your own Theme if it's more convenient
        sdk.theme = OwnTheme()
    }
}

fileprivate class OwnTheme: SNSTheme {
    override init() {
        super.init()
        
        sns_CameraScreenTorchButtonTintColor = .white
    }
}

// MARK: - Helpers

extension IdentityVerification {
    
    private static func log(_ message: String) {
        print(Date.formatted, "[IdentityVerification] " + message)
    }
    
    private static func logAndAlert(_ message: String) {
        log(message)
        App.showAlert(message)
    }
}
