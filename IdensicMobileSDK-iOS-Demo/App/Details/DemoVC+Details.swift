//
//  DemoVC+Details.swift
//  IdensicMobileSDK-iOS-Demo
//
//  Created by Sergey Kokunov on 19.06.2020.
//  Copyright © 2020 Sum & Substance. All rights reserved.
//

import UIKit

extension DemoVC {
    
    static var controller: UIViewController { return App.storyboard.instantiateViewController(withIdentifier: "DemoVC") }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        view.backgroundColor = .bgColor
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        redraw()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        App.checkAutorizationStatus()
    }
    
    func redraw(animated: Bool = false) {
        
        if animated {
            UIView.animate(withDuration: 0.5) {
                self._redraw()
            }
        } else {
            _redraw()
        }
    }
    
    private func _redraw() {
        
        let hasCurrent = YourUser.hasCurrent
        
        userDropdown.text = hasCurrent ? YourUser.userId : nil
        userDropdown.isEnabled = hasCurrent
        
        langDropdown.text = hasCurrent ? Language.current.name : nil
        langDropdown.isEnabled = hasCurrent
        
        verificationButton.isEnabled = hasCurrent
        
        userButton.stopActivity()
    }

    // MARK: -
    
    @IBAction func makeNewUser(_ sender: Any) {

        self.userButton.startActivity()
        
        YourBackend.getApplicantFlows { [weak self] (error, flows) in
            
            guard let self = self else { return }
            
            self.userButton.stopActivity()
            
            if let error = error {
                self.showAlert(for: error) {
                    App.checkAutorizationStatus()
                }
                return
            }
            
            guard let flows = flows, flows.count > 0 else {
                self.showNoFlowsAlert()
                return
            }
            
            self.showSelect(from: sender, flows, "Select Applicant Flow") { (flowName) in
                
                guard let flowName = flowName else { return }
                
                YourUser.makeNewUser(with: flowName)
                self.log("New user has been created with userId: \(YourUser.userId ?? "<null>"), flowName: \(YourUser.flowName)")

                self.redraw(animated: true)
            }
        }
    }
    
    func showNoFlowsAlert() {
        
        let alert = AlertController(
            message: "It seems no applicant flows are defined yet. Please, set up one or more with the Dashboard:\n\nSDK Integrations -> Verification Flows"
        )
        
        alert.addAction("Dashboard") {
            if let url = SumSubAccount.linkTo("/checkus#/sdkIntegrations/flows") {
                UIApplication.shared.openURL(url)
            }
        }
        alert.addCancelAction()
        
        alert.preset(from: self)
    }
    
    // MARK: -
    
    enum ApplicantMenu: String, Selectable {
        case showUserId = "Show User Id"
        case showFlowName = "Show Flow Name"
        case share = "Share…"
    }
        
    @IBAction func showApplicantMenu(_ sender: Any) {
        
        showSelect(from: sender, ApplicantMenu.self) { (action) in
            
            guard let action = action else { return }
            
            switch action {
            case .showUserId:
                self.userDropdown.text = YourUser.userId
                
            case .showFlowName:
                self.userDropdown.text = YourUser.flowName
                
            case .share:
                let objectToShare = self.userDropdown.text ?? "Not created yet"
                
                let vc = UIActivityViewController(activityItems: [objectToShare], applicationActivities: nil)
                
                if let view = sender as? UIView {
                    vc.popoverPresentationController?.sourceView = view
                    vc.popoverPresentationController?.sourceRect = view.bounds
                }
                
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Language
    
    @IBAction func selectLang(_ sender: Any) {
        
        showSelect(from: sender, Language.self) { (lang) in
            if let lang = lang {
                Language.setCurrent(lang)
                self.redraw()
            }
        }
    }

    // MARK: - Logging
    
    func log(_ message: String) {
        print(Date.formatted, "[DemoVC] " + message)
    }
    
}
