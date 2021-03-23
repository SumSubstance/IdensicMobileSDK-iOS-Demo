//
//  DemoVC+Details.swift
//  IdensicMobileSDK-iOS-Demo
//
//  Created by Sergey Kokunov on 19.06.2020.
//  Copyright © 2020 Sum & Substance. All rights reserved.
//

import UIKit

class DemoVC: UIViewController {
    
    static var controller: UIViewController { return App.storyboard.instantiateViewController(withIdentifier: "DemoVC") }

    @IBOutlet weak var userDropdown: DropdownField!
    @IBOutlet weak var userButton: Button!
    
    @IBOutlet weak var flowDropdown: DropdownField!
    @IBOutlet weak var langDropdown: DropdownField!
    @IBOutlet weak var verificationButton: Button!
    
    private var observer: NSObjectProtocol?
    
    // MARK: - Lifecycle
    
    deinit {
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
        
    override func awakeFromNib() {
        super.awakeFromNib()
        
        view.backgroundColor = .bgColor
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        redraw()
        
        observer =
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification,
                                               object: nil,
                                               queue: .main)
        { (notification) in

            guard SumSubAccount.isAuthorized, !SumSubAccount.hasCredentials else { return }
            
            YourBackend.checkIsAuthorized { (error, isAuthorized) in
                
                if error != nil || isAuthorized || !SumSubAccount.isAuthorized { return }
                
                YourBackend.bearerToken = nil

                App.checkAutorizationStatus()
            }
        }
    }

    // MARK: -
    
    private func redraw(animated: Bool = false) {
        
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
        
        flowDropdown.text = hasCurrent ? YourUser.flowName : nil
        flowDropdown.isEnabled = hasCurrent
        
        langDropdown.text = hasCurrent ? Language.current.name : nil
        langDropdown.isEnabled = hasCurrent
        
        verificationButton.isEnabled = hasCurrent
        
        userButton.stopActivity()
    }

    // MARK: - Actions
    
    @IBAction func makeNewUser(_ sender: Any) {
        
        selectFlow(sender, forNewUser: true) { (flow) in
            
            YourUser.makeNewUser(with: flow)
            self.log("New user has been created with userId: \(YourUser.userId ?? "<null>"), flowName: \(YourUser.flowName)")
            
            self.redraw(animated: true)
        }
    }
    
    @IBAction func selectFlow(_ sender: Any) {
        
        selectFlow(sender, forNewUser: false) { (flow) in
            YourUser.setFlow(flow)
            self.log("New flow has been selected for userId: \(YourUser.userId ?? "<null>"), flowName: \(YourUser.flowName)")
            self.redraw(animated: true)
        }
    }
    
    // MARK: -
    
    private func selectFlow(_ sender: Any, forNewUser: Bool = false, onSelect: @escaping (Flow) -> Void) {

        if forNewUser {
            userButton.startActivity()
        } else {
            flowDropdown.startActivity()
        }
        
        YourBackend.getApplicantFlows(forNewUser: forNewUser) { [weak self] (error, flows) in
            
            guard let self = self else { return }
            
            if forNewUser {
                self.userButton.stopActivity()
            } else {
                self.flowDropdown.stopActivity()
            }
            
            if let error = error {
                
                if App.checkAutorizationStatus() {
                    self.showAlert(for: error)
                }
                return
            }
            
            guard let flows = flows, flows.count > 0 else {
                self.showNoFlowsAlert()
                return
            }
            
            self.showSelect(from: sender, flows, "Select Applicant Flow") { (flow) in
                
                if let flow = flow {
                    onSelect(flow)
                }
            }
        }
    }

    private func showNoFlowsAlert() {
        
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
    
    private enum ApplicantMenu: String, Selectable {
        case share = "Share…"
    }
        
    @IBAction func showApplicantMenu(_ sender: Any) {
        
        showSelect(from: sender, ApplicantMenu.self) { (action) in
            
            guard let action = action else { return }
            
            switch action {
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
    
    private func log(_ message: String) {
        print(Date.formatted, "[DemoVC] " + message)
    }
    
}
