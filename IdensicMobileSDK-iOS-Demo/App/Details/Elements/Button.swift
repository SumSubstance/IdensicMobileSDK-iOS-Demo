//
//  Button.swift
//  IdensicMobileSDK-iOS-Demo
//
//  Created by Sergey Kokunov on 21/05/2020.
//  Copyright © 2020 Sum & Substance. All rights reserved.
//

import UIKit

class Button: UIButton {

    struct Layout {
        static let cornerRadius = CGFloat(8)
    }
    
    fileprivate var normalBgColor: UIColor? {
        didSet {
            backgroundColor = normalBgColor
        }
    }
    fileprivate var highlightedBgColor: UIColor?

    private lazy var activityIndicator = UIActivityIndicatorView(style: .white)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setTitleColor(.actionFgColor, for: .normal)
        
        normalBgColor = .actionBgColor
        highlightedBgColor = normalBgColor?.withAlphaComponent(0.8)
        
        activityIndicator.color = titleColor(for: .normal)
        
        layer.cornerRadius = Layout.cornerRadius
    }
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? highlightedBgColor : normalBgColor
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            alpha = isEnabled ? 1 : 0.5
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if isBusy, let titleLabel = titleLabel {
            activityIndicator.center = titleLabel.center
        }
    }
    
    private var isBusy = false

    func startActivity() {
        
        redraw(isBusy: true)
    }
    
    func stopActivity() {
        redraw(isBusy: false)
    }
        
    private func redraw(isBusy: Bool) {
        
        if self.isBusy == isBusy {
            return
        }
        
        self.isBusy = isBusy
        
        if isBusy {
            if activityIndicator.superview != self {
                addSubview(activityIndicator)
            }
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        
        activityIndicator.alpha = isBusy ? 1 : 0
        titleLabel?.alpha = isBusy ? 0 : 1
        
        isUserInteractionEnabled = !isBusy
    }
}

class AlternativeButton: Button {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        normalBgColor = .alternativeBgColor
        highlightedBgColor = normalBgColor?.withAlphaComponent(0.8)
    }
}

class SecondaryButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let highlightedColor = UIColor.textColor
        let normalColor = highlightedColor.withAlphaComponent(0.75)

        setTitleColor(normalColor, for: .normal)
        setTitleColor(highlightedColor, for: .highlighted)

        if let attributedTitle = attributedTitle(for: .normal) {
            setAttributedTitle(colorize(attributedTitle, with: normalColor), for: .normal)
        }

        if let attributedTitle = attributedTitle(for: .highlighted) ?? attributedTitle(for: .normal) {
            setAttributedTitle(colorize(attributedTitle, with: highlightedColor), for: .highlighted)
        }
    }
        
    private func colorize(_ attributedTitle: NSAttributedString, with color: UIColor) -> NSAttributedString {
        
        let attributedString = NSMutableAttributedString(attributedString: attributedTitle)
        attributedString.addAttributes([.foregroundColor: color], range: NSMakeRange(0, attributedString.length))
        
        return attributedString
    }
}
