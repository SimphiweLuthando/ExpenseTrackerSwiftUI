//
//  Extensions.swift
//  ExpenseTracker
//
//  Created by Simphiwe Mbokazi on 15/07/23.
//  

//

import Foundation

extension Double {
    
    var formattedCurrencyText: String {
        return Utils.numberFormatter.string(from: NSNumber(value: self)) ?? "0"
    }
    
}
