//
//  UIImage+Extensions.swift
//  IdensicMobileSDK-iOS-Demo
//
//  Created by Sergey Kokunov on 18.03.2021.
//  Copyright © 2021 Sum & Substance. All rights reserved.
//

import UIKit

extension UIImage {
    
    func tint(with tintColor: UIColor) -> UIImage {

        UIGraphicsBeginImageContextWithOptions(size, false, 0)

        guard let context = UIGraphicsGetCurrentContext(),
              let cgImage = cgImage else
        {
            return self
        }

        let drawRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.setBlendMode(.normal)
        context.setAlpha(tintColor.cgColor.alpha)
        context.draw(cgImage, in: drawRect)
        context.setFillColor(tintColor.cgColor)
        context.setBlendMode(.sourceAtop)
        context.fill(drawRect)
        
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let tintedImage = tintedImage?.withRenderingMode(.alwaysOriginal) {
            return flipsForRightToLeftLayoutDirection ? tintedImage.imageFlippedForRightToLeftLayoutDirection() : tintedImage;
        } else {
            return self
        }
    }
}
