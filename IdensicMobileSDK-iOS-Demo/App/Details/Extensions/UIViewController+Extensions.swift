//
//  UIViewController+Extensions.swift
//  IdensicMobileSDK-iOS-Demo
//
//  Created by Sergey Kokunov on 21/05/2020.
//  Copyright © 2020 Sum & Substance. All rights reserved.
//

import UIKit

protocol Stringable {
    var toString: String? { get }
}

protocol Selectable: CaseIterable, Stringable {
    var name: String { get }
}

extension Selectable where Self: RawRepresentable, Self.RawValue == String {
    var name: String {
        return self.rawValue
    }
    var toString: String? {
        return name
    }
}

// MARK: -

extension UIViewController {
    
    func showAlert(for error: Error, actionHandler: (() -> Void)? = nil) {
        
        showAlert(error.localizedDescription, actionHandler: actionHandler)
    }
    
    func showAlert(_ message: String, actionHandler: (() -> Void)? = nil) {
        
        let alert = AlertController(message: message)
        
        alert.addAction("OK", handler: actionHandler)
        alert.present(from: self)
    }

    func showSelect<T:Selectable>(from sender: Any?, _ list: T.Type, _ message: String? = nil, onComplete: @escaping (T?) -> Void) {
        
        var items = [Any]()
        
        for option in list.allCases {
            items.append(option)
        }
        
        showSelect(from: sender, items, message) { (item) in
            onComplete(item as? T)
        }
    }
    
    func showSelect<T>(from sender: Any?, _ items: [T], _ message: String? = nil, onComplete: @escaping (T?) -> Void) {
        
        let sheet = AlertController(
            title: message == nil ? nil : "",
            message: message,
            preferredStyle: .actionSheet
        )
        
        if let sender = sender as? UIView {
            sheet.popoverPresentationController?.sourceView = sender
            sheet.popoverPresentationController?.sourceRect = sender.bounds
        }

        var title: String?
        
        for item in items {
            if let item = item as? Stringable {
                title = item.toString
            } else {
                title = "\(item)"
            }
            sheet.addAction(title) {
                onComplete(item)
            }
        }
        
        sheet.addCancelAction() {
            onComplete(nil)
        }
        
        sheet.present(from: self)
    }
    
    func hideKeyboard() {
        
        UIApplication.shared.sendAction(#selector(resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
