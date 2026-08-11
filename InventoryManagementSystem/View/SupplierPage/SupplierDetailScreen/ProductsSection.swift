//
//  ProductsSection.swift
//  InventoryManagementSystem
//
//  Created by iPHTech 30 on 10/08/26.
//

import SwiftUI
import CoreData

struct ProductsSection: View {
    
    let supplier: Supplier
    
    private var products: [Product] {
        (supplier.supplier_product as? Set<Product>)?
            .sorted { ($0.name ?? "") < ($1.name ?? "") } ?? []
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "cube.box")
                    .font(.headline)
                    .foregroundStyle(.blue)
                Text("Products Supplied by this Supplier")
                    .font(.headline)
            }
            
            Divider()
            
            if products.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "cube.box")
                        .font(.system(size: 40))
                        .foregroundStyle(.gray.opacity(0.5))
                    Text("No Products")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                    Text("This supplier has not supplied any products yet.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            } else {
                VStack(spacing: 0) {
                    ForEach(products, id: \.objectID) { product in
                        NavigationLink {
                            ProductDetailPage(product: product)
                        } label: {
                            SupplierProductRow(product: product)
                        }
                        .buttonStyle(.plain)
                        
                        if product.objectID != products.last?.objectID {
                            Divider()
                                .padding(.leading, 56)
                        }
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
