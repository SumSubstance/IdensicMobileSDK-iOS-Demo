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
    
    @IBOutlet weak var levelDropdown: DropdownField!
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
        
        levelDropdown.text = hasCurrent ? Storage.levelName : nil
        levelDropdown.isEnabled = hasCurrent

        if SumSubAccount.isFlowBased {
            levelDropdown.placeholder = "Applicant Flow"
            levelDropdown.text = hasCurrent ? Storage.flowName : nil
        }

        langDropdown.text = hasCurrent ? Language.current.name : nil
        langDropdown.isEnabled = hasCurrent
        
        let hasLevel = levelDropdown.text != nil && !levelDropdown.text!.isEmpty
        
        verificationButton.isEnabled = hasCurrent && hasLevel
        
        userButton.stopActivity()
    }

    // MARK: - Actions
    
    @IBAction func makeNewUser(_ sender: Any) {
        
        if SumSubAccount.isFlowBased { return makeNewFlowBasedUser(sender) }
        
        selectLevel(sender, forNewUser: true) { level in
            self.log("New user has been created with userId: \(YourUser.userId ?? "<null>"), levelName: \(level.name)")
            YourUser.makeNewUser(with: level)
            self.redraw(animated: true)
        }
    }
    
    @IBAction func selectLevel(_ sender: Any) {
        
        if SumSubAccount.isFlowBased { return selectFlow(sender) }
        
        selectLevel(sender, forNewUser: false) { level in
            self.log("New level has been selected for userId: \(YourUser.userId ?? "<null>"), levelName: \(level.name)")
            YourUser.setLevel(level)
            self.redraw(animated: true)
        }
    }
    
    @IBAction func launchVerification(_ sender: Any) {
        
        if SumSubAccount.isFlowBased { return launchFlowBasedVerification() }
        
        launchVerification()
    }
    
    // MARK: -
    
    private func selectLevel(_ sender: Any, forNewUser: Bool = false, onSelect: @escaping (ApplicantLevel) -> Void) {

        if forNewUser {
            userButton.startActivity()
        } else {
            levelDropdown.startActivity()
        }

        YourBackend.getApplicantLevels(forNewUser: forNewUser) { [weak self] (error, levels) in
            
            guard let self = self else { return }

            self.userButton.stopActivity()
            self.levelDropdown.stopActivity()
            
            if let error = error {

                if App.checkAutorizationStatus() {
                    self.showAlert(for: error)
                }
                return
            }
            
            guard let levels = levels, levels.count > 0 else {
                self.showNoLevelsAlert()
                return
            }
            
            self.showSelect(from: sender, levels, "Select Applicant Level") { (level) in
                
                if let level = level {
                    onSelect(level)
                }
            }
        }
        
    }

    private func showNoLevelsAlert() {
        
        let alert = AlertController(
            message: "It seems no applicant levels are defined yet. Please, set up one or more with the Dashboard:\n\nSDK Integrations -> Applicant Levels"
        )
        
        alert.addAction("Dashboard") {
            if let url = SumSubAccount.linkTo("/checkus#/sdkIntegrations/levels") {
                UIApplication.shared.openURL(url)
            }
        }
        alert.addCancelAction()
        
        alert.present(from: self)
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

// MARK: - Flow-based way

extension DemoVC {
    
    private func makeNewFlowBasedUser(_ sender: Any) {
        
        selectFlow(sender, forNewUser: true) { flow in
            self.log("New user has been created with userId: \(YourUser.userId ?? "<null>"), flowName: \(flow.name)")
            YourUser.makeNewUser(with: flow)
            self.redraw(animated: true)
        }
    }
    
    private func selectFlow(_ sender: Any) {
        
        selectFlow(sender, forNewUser: false) { flow in
            self.log("New flow has been selected for userId: \(YourUser.userId ?? "<null>"), flowName: \(flow.name)")
            YourUser.setFlow(flow)
            self.redraw(animated: true)
        }
    }
    
    private func selectFlow(_ sender: Any, forNewUser: Bool = false, onSelect: @escaping (ApplicantFlow) -> Void) {
        
        if forNewUser {
            userButton.startActivity()
        } else {
            levelDropdown.startActivity()
        }
        
        YourBackend.getApplicantFlows(forNewUser: forNewUser) { [weak self] (error, flows) in
            
            guard let self = self else { return }
            
            self.userButton.stopActivity()
            self.levelDropdown.stopActivity()
            
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
        
        alert.present(from: self)
    }
    
    public func launchFlowBasedVerification() {
        
        IdentityVerification.launch(
            from: self,
            for: YourUser.current,
            flowName: Storage.flowName ?? "",
            locale: Language.locale
        )
    }
}
