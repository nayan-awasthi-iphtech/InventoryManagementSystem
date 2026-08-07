//
//  ProductDetailPage.swift
//  InventoryManagementSystem
//
//  Created by iPHTech 30 on 07/08/26.
//

import SwiftUI
import CoreData

struct ProductDetailPage: View {
    
    @ObservedObject var product: Product
    @State private var showEditSheet: Bool = false
    @State private var showDeleteAlert: Bool = false
    @StateObject private var viewModel = ProductViewModel()
    
    var body: some View {
        ScrollView{
            VStack(spacing: 16) {
                
                if let data = product.imageData , let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 150)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemGray6))
                            .frame(width:160, height: 150)
                        
                        VStack(spacing: 8) {
                            Image(systemName: "shippingbox.fill")
                                .font(.system(size: 48))
                                .foregroundStyle(.gray)
                            Text("No Image Available")
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                    }
                }
                
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(product.name ?? "")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        if let categoryName = product.product_category?.name {
                            Text(categoryName)
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.12))
                                .foregroundStyle(.blue)
                                .clipShape(Capsule())
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("$\(product.price, specifier: "%.2f")")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.green)
                        
                        HStack(spacing: 4) {
                            Circle()
                                .fill(product.quantity < 5 ? Color.red : Color.green)
                                .frame(width: 8, height: 8)
                            Text("\(product.quantity) in stock")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10){
                InfoTile(title: "SKU", value: product.sku ?? "N/A", icon: "barcode")
                InfoTile(title: "Barcode", value: product.barcode ?? "N/A", icon: "qrcode")
                InfoTile(title: "Category", value: product.product_category?.name ?? "", icon: "folder")
                InfoTile(title: "Supplier", value: product.product_Supplier?.name ?? "", icon: "building.2")
            }
            
            
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "folder.badge.gearshape")
                        .font(.headline)
                        .foregroundStyle(.blue)
                    Text("Classification")
                        .font(.headline)
                }
                
                Divider()
                
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "folder")
                            .foregroundStyle(.secondary)
                            .frame(width: 20)
                        Text("Category")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(product.product_category?.name ?? "Uncategorized")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                }
                
                Divider()
                    .padding(.leading, 28)
                
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "building.2")
                            .foregroundStyle(.secondary)
                            .frame(width: 20)
                        Text("Supplier")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(product.product_Supplier?.name ?? "No Supplier")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            VStack(alignment: .leading, spacing: 10){
                HStack {
                    Image(systemName: "doc.text")
                        .foregroundStyle(.blue)
                    Text("Description")
                        .font(.headline)
                }
                
                Divider()
                
                Text((product.detail?.isEmpty == false) ? product.detail! : "No detail for this product is available")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineSpacing(4)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .background(Color(.secondarySystemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Product Overiew")
        .toolbar{
            ToolbarItemGroup(placement: .topBarTrailing){
                Button {
                    showEditSheet = true
                } label: {
                    Image(systemName: "square.and.pencil")
                        .foregroundStyle(.blue)
                }
                
                Button(role: .destructive) {
                    showDeleteAlert = true
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(.red)
                }
            }
        }
        .sheet(isPresented: $showEditSheet){
            AddEditProductView(productToEdit: product)
                .environmentObject(viewModel)
        }
        .confirmationDialog("Product Delete" , isPresented: $showDeleteAlert){
            Button("Delete", role: .destructive){
                viewModel.deleteProduct(product)
            }
            Button("Cancel") {
                
            }
        } message: {
            Text("Are you sure you want to delete '\(product.name ?? "this product")'? This action cannot be undone.")
        }
    }
}

struct InfoTile: View {
    let title: String
    let value: String
    let icon: String
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 36, height: 36)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2)
                    .foregroundStyle(.gray)
                Text(value.isEmpty ? "N/A" : value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
            }
            Spacer()
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    
    let sampleProduct = Product(context: context)
    sampleProduct.name = "Sample Headphones"
    sampleProduct.price = 2999.00
    sampleProduct.quantity = 10
    
    return NavigationStack {
        ProductDetailPage(product: sampleProduct)
            .environmentObject(ProductViewModel())
    }
}
