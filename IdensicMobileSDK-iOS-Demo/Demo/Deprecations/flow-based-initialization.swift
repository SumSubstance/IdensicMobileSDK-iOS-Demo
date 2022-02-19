//
//  flow-based-initialization.swift
//  IdensicMobileSDK-iOS-Demo
//
//  Created by Roman Silin on 13.08.2021.
//  Copyright © 2021 Sum & Substance. All rights reserved.
//

import Foundation
import IdensicMobileSDK

#if USE_FLOW_BASED_INITIALIZATION
extension IdentityVerification {
    //
    // WARNING:
    // Pay attention please that the flow-based initialization is deprecated and will be removed in the near future,
    // please adopt the level-based one, see IdentityVerification.swift for details.
    //
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
        //    that is bound to your user. The access token is valid for a rather short period of time and when it's expired
        //    you must provide another one. In order to do so you will ask your backend and most likely the backend
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
        
        // MARK: Initialization
        //
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
        
        // MARK: tokenExpirationHandler
        //
        // The access token has a limited lifespan and when it's expired, you must provide another one.
        // Get a new token using your backend, then call `onComplete` to pass the new token back.
        //
        sdk.tokenExpirationHandler { (onComplete) in
            
            YourBackend.getAccessToken(for: user) { (error, newToken) in
                
                if let error = error {
                    log("Failed to get new access token from the backend: \(error.localizedDescription)")
                }
                
                onComplete(newToken)
            }
        }
        
        // MARK: Advanced Setup
        //
        // It's optional and could be skipped
        //
        setupLogging()
        setupHandlers()
        setupCallbacks()
        setupSupportItems()
        setupTheme()
        
        // MARK: Presentation
        //
        log("Presentation")
        
        yourVC.present(sdk.mainVC, animated: true, completion: nil)
        
    }
}
#endif
