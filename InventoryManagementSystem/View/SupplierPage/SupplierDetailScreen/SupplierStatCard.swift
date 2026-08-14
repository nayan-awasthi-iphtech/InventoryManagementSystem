//
//  SupplierStatCard.swift
//  InventoryManagementSystem
//
//  Created by iPHTech 30 on 10/08/26.
//

import SwiftUI

struct SupplierStatCard: View {
    let icon: String
    let color: Color
    let value: String
    let label: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(color)
                .padding(6)
                .background(color.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 4))
            
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(AppTheme.primaryText)
            
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(AppTheme.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(AppTheme.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
    }
}