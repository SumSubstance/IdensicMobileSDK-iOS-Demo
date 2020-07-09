//
//  Label.swift
//  IdensicMobileSDK-iOS-Demo
//
//  Created by Sergey Kokunov on 20.06.2020.
//  Copyright © 2020 Sum & Substance. All rights reserved.
//

import UIKit

class Label: UILabel {

    override func awakeFromNib() {
        superview?.awakeFromNib()

        textColor = .textColor
    }
}
