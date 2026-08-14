//
//  INRCompactFormatter.swift
//  InventoryManagementSystem
//
//  Created by iPHTech 30 on 12/08/26.
//

import Foundation

enum INRCompactFormatter {
    
    static func string(from amount: Double) -> String {
        "₹" + compactNumber(amount)
    }
    
    static func string(from amount: Int) -> String {
        compactNumber(Double(amount))
    }
    
    private static func compactNumber(_ amount: Double) -> String {
        let crore = 10_000_000.0
        let lakh = 100_000.0
        let thousand = 1_000.0
        
        let value: String
        switch amount {
        case crore...:
            value = compact(amount / crore, suffix: "cr")
        case lakh...:
            value = compact(amount / lakh, suffix: "L")
        case thousand...:
            value = compact(amount / thousand, suffix: "k")
        default:
            value = String(format: "%.0f", max(amount, 0))
        }
        return value
    }
    
    private static func compact(_ value: Double, suffix: String) -> String {
        if value == value.rounded() {
            return String(format: "%.0f", value) + suffix
        }
        return String(format: "%.1f", value) + suffix
    }
}
