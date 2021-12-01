//
//  ScanVC+Details.swift
//  IdensicMobileSDK-iOS-Demo
//
//  Created by Sergey Kokunov on 22.03.2021.
//  Copyright © 2021 Sum & Substance. All rights reserved.
//

import UIKit
import AVFoundation

class ScanVC: UIViewController {
    
    static var controller: UIViewController { return App.storyboard.instantiateViewController(withIdentifier: "ScanVC") }
    
    @IBOutlet weak var previewView: CaptureVideoPreviewView!
    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var infoLabel: Label!
    @IBOutlet weak var statusLabel: Label!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var dimView: UIView!
    @IBOutlet weak var scannerLine: UIView!
    
    private let sessionQueue = DispatchQueue(label: "scanCaptureSession")

    private lazy var captureSession = AVCaptureSession()
    private lazy var jsonDecoder = JSONDecoder()
    
    private var isSessionInitialized = false
    private var isProcessing = false
    
    // MARK: -
    
    struct QRCode: Codable {
        let url: String
        let t: String
        let sbx: Int?
        let c: String?
        
        var isSandbox: Bool { (sbx ?? 0) > 0 }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.alpha = 0
        scannerLine.alpha = 0
        scannerLine.layer.cornerRadius = 2
        
        view.backgroundColor = .bgColor
        tintImages()
        
        if hasCameraPermission {
            startActivity()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sessionQueue.async {
            if self.isSessionInitialized && !self.captureSession.isRunning {
                self.captureSession.startRunning()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard isMovingToParent else { return }
        
        ensurePermissions { (isGranted) in
            if isGranted {
                self.setupCaptureSession()
            } else {
                self.showAlert("The application doesn't have permission to use the camera, please change the privacy settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.openURL(url)
                    }
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        sessionQueue.async {
            if self.isSessionInitialized && self.captureSession.isRunning {
                self.captureSession.stopRunning()
            }
        }
        
        super.viewWillDisappear(animated)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        updateVideoOrientation()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
        if #available(iOS 12.0, *) {
            if previousTraitCollection == nil || traitCollection.userInterfaceStyle != previousTraitCollection!.userInterfaceStyle {
                tintImages()
            }
        }
    }
    
    // MARK: - Actions
    
    func logIntoSumSubAccount(with qrCode: QRCode, onSuccess: @escaping () -> Void) {
        
        App.playSuccess()
        
        SumSubAccount.username = ""
        SumSubAccount.password = ""
        
        SumSubAccount.apiUrl = qrCode.url
        SumSubAccount.isSandbox = qrCode.isSandbox
        YourBackend.bearerToken = qrCode.t
        YourBackend.client = qrCode.c
        
        showStatusProcessing { [weak self] in
            
            YourBackend.logIntoSumSubAccount(delay: 0.5) { (error, isAuthorized) in
                
                if isAuthorized {
                    SumSubAccount.save()
                    onSuccess()
                    return
                }
                
                YourBackend.bearerToken = nil
                SumSubAccount.save()
                
                if let error = error {
                    self?.showError(error)
                } else {
                    self?.showPromptToReloadWebPage()
                }
            }
        }
    }
    
    // MARK: - Camera
    
    private var hasCameraPermission: Bool {
        
        return AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    }
    
    private func ensurePermissions(onComplete: @escaping (Bool) -> Void) {
        
        if self.hasCameraPermission {
            DispatchQueue.main.async {
                onComplete(true)
            }
            return
        }
        
        AVCaptureDevice.requestAccess(for: .video) { (isGranted) in
            DispatchQueue.main.async {
                onComplete(isGranted)
            }
        }
    }
    
    private func setupCaptureSession() {
        
        startActivity()
        
        configureCaptureSession { [weak self] (error) in
            
            guard let self = self else { return }
            
            self.previewView.videoPreviewLayer.session = self.captureSession
            self.previewView.videoPreviewLayer.videoGravity = .resizeAspectFill
            self.updateVideoOrientation()
                        
            if let error = error {
                self.stopActivity()
                self.showAlert(for: error) { [weak self] in
                    self?.navigationController?.popViewController(animated: true)
                }
                return
            }
            
            self.sessionQueue.async {
                self.isSessionInitialized = true
                self.captureSession.startRunning()
                
                DispatchQueue.main.async {
                    self.stopActivity()
                }
            }
        }
    }
    
    private func configureCaptureSession(onComplete: @escaping (Error?) -> Void) {
        
        sessionQueue.async {
            
            let error = self._configureCaptureSession()

            DispatchQueue.main.async {
                onComplete(error)
            }
        }
    }
    
    private func _configureCaptureSession() -> Error? {
        
        captureSession.beginConfiguration()
        defer { captureSession.commitConfiguration() }
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            return NSError("Unable to create AVCaptureDevice")
        }
        
        let deviceInput: AVCaptureDeviceInput
        
        do {
            deviceInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return error
        }
        
        if captureSession.canAddInput(deviceInput) {
            captureSession.addInput(deviceInput)
        } else {
            return NSError("Unable to use the camera")
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
        } else {
            return NSError("Unable to use the metadata output")
        }
        
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = [.qr]
                
        return nil
    }
    
    private func updateVideoOrientation() {
        
        let deviceOrientation = UIDevice.current.orientation
        
        if deviceOrientation.isPortrait || deviceOrientation.isLandscape,
           let videoOrientation = AVCaptureVideoOrientation(rawValue: deviceOrientation.rawValue)
        {
            previewView.videoPreviewLayer.connection?.videoOrientation = videoOrientation
        }
    }
    
    // MARK: - Helpers
    
    private func tintImages() {
        
        qrImageView.image = qrImageView.image?.tint(with: .textColor)
    }
    
    private func startActivity() {
        
        if activityIndicator.alpha > 0 {
            return
        }
        
        UIView.animate(withDuration: 0.15) {
            self.dimView.alpha = 0.25
            self.activityIndicator.alpha = 1
            self.activityIndicator.startAnimating()
        }
    }
    
    private func stopActivity() {
        
        UIView.animate(withDuration: 0.15) {
            self.dimView.alpha = 0
            self.activityIndicator.alpha = 0
            self.activityIndicator.stopAnimating()
        }
    }
    
    private func scanIcon() {
        
        let anim = CABasicAnimation(keyPath: "position.y")
        anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        anim.duration = 0.5
        anim.fromValue = qrImageView.frame.minY + 2
        anim.toValue = qrImageView.frame.maxY - 2
        anim.isRemovedOnCompletion = false
        anim.fillMode = .forwards
        anim.autoreverses = true
        anim.repeatCount = .infinity
        
        qrImageView.layer.removeAnimation(forKey: "shake")
        scannerLine.layer.add(anim, forKey: "scan")
        
        UIView.animate(withDuration: 0.15) {
            self.scannerLine.alpha = 0.75
        }
    }
    
    private func shakeIcon() {
        
        App.playWarning()
        
        let anim = CAKeyframeAnimation(keyPath: "transform.translation.x")
        anim.timingFunction = CAMediaTimingFunction(name: .linear)
        anim.duration = 0.5
        anim.values = [-16.0, 16.0, -8.0, 8.0, -4.0, 4.0, 0.0]
        
        qrImageView.layer.add(anim, forKey: "shake")
        
        UIView.animate(withDuration: 0.15) {
            self.scannerLine.alpha = 0
        } completion: { _ in
            self.scannerLine.layer.removeAnimation(forKey: "scan")
        }
    }
    
    private func showError(_ error: Error) {
        
        shakeIcon()
        showStatus(nil) {
            self.showAlert(for: error) { [weak self] in
                self?.enableScanning(in: 1)
            }
        }
    }
    
    private func showStatusProcessing(onComplete: @escaping () -> Void) {
        
        scanIcon()
        showStatus("Processing...", onComplete: onComplete)
    }
    
    private func showPromptToReloadWebPage() {
        
        shakeIcon()
        showStatus("Seems the code is expired, please reload the webpage then scan it once again") {
            self.enableScanning(in: 5)
        }
    }
    
    private func showPromptToScan() {
        
        shakeIcon()
        showStatus(nil) {
            self.enableScanning(in: 2)
        }
    }
    
    private func showStatus(_ status: String? = nil, onComplete: @escaping () -> Void) {
        
        let hasStatus = status != nil
        
        UIView.animate(withDuration: 0.25) {
            
            self.infoLabel.alpha = 0;
            self.statusLabel.alpha = 0;
            
        } completion: { _ in
            
            self.statusLabel.text = status
            
            UIView.animate(withDuration: 0.25) {
                
                self.infoLabel.alpha = hasStatus ? 0 : 1;
                self.statusLabel.alpha = hasStatus ? 1 : 0;
                
                onComplete()
            }
        }
    }
    
    private func enableScanning(in delay: TimeInterval = 0) {
        
        DispatchQueue.main.asyncAfter(deadline: .now()+delay) { [weak self] in
            
            self?.isProcessing = false
        }
    }
}

extension ScanVC: AVCaptureMetadataOutputObjectsDelegate {
    
    internal func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if isProcessing { return } else { isProcessing = true }
        
        if let metadataObject = metadataObjects.first,
           let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject
        {
            if let stringValue = readableObject.stringValue,
               let jsonData = Data(base64Encoded: stringValue),
               let qrCode = try? jsonDecoder.decode(QRCode.self, from: jsonData)
            {
                didScan(qrCode: qrCode)
            } else {
                showPromptToScan()
            }
        }
    }
}

// MARK: -

class CaptureVideoPreviewView: UIView {
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return self.layer as! AVCaptureVideoPreviewLayer
    }
}
