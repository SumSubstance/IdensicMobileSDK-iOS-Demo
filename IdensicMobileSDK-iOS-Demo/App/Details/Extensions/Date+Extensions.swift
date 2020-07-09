//
//  Date+Extensions.swift
//  IdensicMobileSDK-iOS-Demo
//
//  Created by Sergey Kokunov on 20.06.2020.
//  Copyright © 2020 Sum & Substance. All rights reserved.
//

import Foundation

extension Date {
    
    private static var formatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return df
    }()
    
    static var formatted: String {
        return formatter.string(from: Date())
    }
}
