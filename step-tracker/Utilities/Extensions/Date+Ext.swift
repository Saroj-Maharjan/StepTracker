//
//  Date+Ext.swift
//  step-tracker
//
//  Created by saroj maharjan on 20/12/2024.
//

import Foundation

extension Date {
    var weekdayInt: Int {
        Calendar.current.component(.weekday, from: self)
    }
    
    var weekdayTitle: String {
        formatted(.dateTime.weekday(.wide))
    }
    
    var accessibilityDate: String {
        formatted(.dateTime.month(.wide).day())
    }
}
