//
//  SupplierProductRow.swift
//  InventoryManagementSystem
//
//  Created by iPHTech 30 on 10/08/26.
//

import SwiftUI

struct SupplierProductRow: View {
    @ObservedObject var product: Product
    
    var body: some View {
        HStack(spacing: 12) {
            Group {
                if let data = product.imageData, let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(AppTheme.accent.opacity(0.15))
                        .overlay(
                            Image(systemName: "cube.fill")
                                .foregroundStyle(AppTheme.accent)
                        )
                }
            }
            .frame(width: 44, height: 44)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name ?? "Unnamed Product")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(AppTheme.primaryText)
                    .lineLimit(1)
                
                Text(product.product_category?.name ?? "Uncategorized")
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(product.price.formatted(.currency(code: "INR")))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.primaryText)
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(product.quantity > 0 ? AppTheme.success : AppTheme.danger)
                        .frame(width: 6, height: 6)
                    Text("Qty: \(product.quantity)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(product.quantity > 0 ? AppTheme.success : AppTheme.danger)
                }
            }
        }
        .padding(.vertical, 8)
    }
}