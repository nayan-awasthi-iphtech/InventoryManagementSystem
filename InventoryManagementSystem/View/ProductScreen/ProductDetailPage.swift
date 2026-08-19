//
//  ProductDetailPage.swift
//  InventoryManagementSystem
//
//  Created by iPHTech 30 on 07/08/26.
//

import SwiftUI
import CoreData

struct ProductDetailPage: View {
    
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var product: Product
    
    @State private var showEditSheet: Bool = false
    @State private var showDeleteAlert: Bool = false
    
    @StateObject private var viewModel = ProductViewModel()
    
    private let qrGenerator = QrCodeGenerator()
    
    private var shortProductID: String {
        guard let id = product.id else {
            return "N/A"
        }
        return String(id.uuidString.prefix(8)).uppercased()
    }
    
    private var qrImage: UIImage? {
        guard let productId = product.id?.uuidString else { return nil }
        return qrGenerator.generateQrCode(from: productId)
    }
    
    var body: some View {
        
        ZStack {
            
            AppTheme.background
                .ignoresSafeArea()
            
            ScrollView {
                
                VStack(spacing: 16) {
                    
                    if let data = product.imageData,
                       let image = UIImage(data: data) {
                        
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .clipShape(
                                RoundedRectangle(cornerRadius: 14)
                            )
                        
                    } else {
                        
                        ZStack {
                            
                            RoundedRectangle(cornerRadius: 14)
                                .fill(AppTheme.cardBackground)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(
                                            Color.primary.opacity(0.06),
                                            lineWidth: 1
                                        )
                                )
                                .frame(width: 150, height: 150)
                            
                            VStack(spacing: 8) {
                                
                                Image(systemName: "shippingbox.fill")
                                    .font(.system(size: 48))
                                    .foregroundStyle(AppTheme.secondaryText)
                                
                                Text("No Image Available")
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.secondaryText)
                            }
                        }
                    }
                    
                    HStack(alignment: .top) {
                        
                        VStack(alignment: .leading, spacing: 6) {
                            
                            Text(product.name ?? "Unknown Product")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(AppTheme.primaryText)
                            
                            if let categoryName = product.product_category?.name {
                                
                                Text(categoryName)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(
                                        AppTheme.accent.opacity(0.12)
                                    )
                                    .foregroundStyle(AppTheme.accent)
                                    .clipShape(Capsule())
                            }
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            
                            Text("₹\(product.price, specifier: "%.2f")")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(AppTheme.success)
                            
                            HStack(spacing: 4) {
                                
                                Circle()
                                    .fill(
                                        product.quantity < 5
                                        ? AppTheme.danger
                                        : AppTheme.success
                                    )
                                    .frame(width: 8, height: 8)
                                
                                Text("\(product.quantity) in stock")
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.secondaryText)
                            }
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(AppTheme.cardBackground)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                Color.primary.opacity(0.06),
                                lineWidth: 1
                            )
                    )
                    
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ],
                        spacing: 10
                    ) {
                        
                        InfoTile(
                            title: "Product ID",
                            value: shortProductID,
                            icon: "number"
                        )
                        
                        InfoTile(
                            title: "SKU",
                            value: product.sku ?? "N/A",
                            icon: "barcode"
                        )
                        
                        InfoTile(
                            title: "Barcode",
                            value: product.barcode ?? "N/A",
                            icon: "qrcode"
                        )
                        
                        InfoTile(
                            title: "Category",
                            value: product.product_category?.name ?? "",
                            icon: "folder"
                        )
                    }
                    
                    VStack(spacing: 14) {
                        
                        HStack {
                            
                            Image(systemName: "qrcode")
                                .foregroundStyle(AppTheme.accent)
                            
                            Text("Product QR Code")
                                .font(.headline)
                                .foregroundStyle(AppTheme.primaryText)
                            
                            Spacer()
                        }
                        
                        Divider()
                        
                        if let qrImage = qrImage {
                            Image(uiImage: qrImage)
                                .interpolation(.none)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 180, height: 180)
                                .padding(12)
                                .background(Color.white)
                                .clipShape(
                                    RoundedRectangle(cornerRadius: 12)
                                )
                            
                            Text("Scan to identify this product")
                                .font(.caption)
                                .foregroundStyle(AppTheme.secondaryText)
                            
                            Text(shortProductID)
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundStyle(AppTheme.accent)
                            
                        } else {
                            
                            Text("Unable to generate QR Code")
                                .font(.caption)
                                .foregroundStyle(AppTheme.secondaryText)
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(AppTheme.cardBackground)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                Color.primary.opacity(0.06),
                                lineWidth: 1
                            )
                    )
                    
                    VStack(alignment: .leading, spacing: 12) {
                        
                        HStack(spacing: 8) {
                            
                            Image(systemName: "folder.badge.gearshape")
                                .font(.headline)
                                .foregroundStyle(AppTheme.accent)
                            
                            Text("Classification")
                                .font(.headline)
                                .foregroundStyle(AppTheme.primaryText)
                        }
                        
                        Divider()
                        
                        HStack {
                            
                            HStack(spacing: 8) {
                                
                                Image(systemName: "folder")
                                    .foregroundStyle(AppTheme.secondaryText)
                                    .frame(width: 20)
                                
                                Text("Category")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(AppTheme.secondaryText)
                            }
                            
                            Spacer()
                            
                            Text(
                                product.product_category?.name
                                ?? "Uncategorized"
                            )
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(AppTheme.primaryText)
                        }
                        
                        Divider()
                            .padding(.leading, 28)
                        
                        HStack {
                            
                            HStack(spacing: 8) {
                                
                                Image(systemName: "building.2")
                                    .foregroundStyle(AppTheme.secondaryText)
                                    .frame(width: 20)
                                
                                Text("Supplier")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(AppTheme.secondaryText)
                            }
                            
                            Spacer()
                            
                            Text(
                                product.product_Supplier?.name
                                ?? "No Supplier"
                            )
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(AppTheme.primaryText)
                        }
                    }
                    .padding(16)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(AppTheme.cardBackground)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                Color.primary.opacity(0.06),
                                lineWidth: 1
                            )
                    )
                    
                    VStack(alignment: .leading, spacing: 10) {
                        
                        HStack {
                            
                            Image(systemName: "doc.text")
                                .foregroundStyle(AppTheme.accent)
                            
                            Text("Description")
                                .font(.headline)
                                .foregroundStyle(AppTheme.primaryText)
                        }
                        
                        Divider()
                        
                        Text(
                            (product.detail?.isEmpty == false)
                            ? product.detail!
                            : "No detail for this product is available"
                        )
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.secondaryText)
                        .lineSpacing(4)
                    }
                    .padding(16)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(AppTheme.cardBackground)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                Color.primary.opacity(0.06),
                                lineWidth: 1
                            )
                    )
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Product Overview")
        .toolbar {
            
            ToolbarItemGroup(placement: .topBarTrailing) {
                
                Button {
                    showEditSheet = true
                } label: {
                    
                    Image(systemName: "square.and.pencil")
                        .foregroundStyle(AppTheme.accent)
                }
                
                Button {
                    showDeleteAlert = true
                } label: {
                    
                    Image(systemName: "trash")
                        .foregroundStyle(AppTheme.danger)
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            
            AddEditProductView(productToEdit: product)
                .environmentObject(viewModel)
        }
        .alert(
            "Product Delete",
            isPresented: $showDeleteAlert
        ) {
            
            Button("Delete", role: .destructive) {
                
                viewModel.deleteProduct(product)
                dismiss()
            }
            
            Button("Cancel", role: .cancel) { }
            
        } message: {
            
            Text(
                "Are you sure you want to delete '\(product.name ?? "this product")'? This action cannot be undone."
            )
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
                .foregroundStyle(AppTheme.accent)
                .frame(width: 36, height: 36)
                .background(
                    AppTheme.accent.opacity(0.1)
                )
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                
                Text(title)
                    .font(.caption2)
                    .foregroundStyle(AppTheme.secondaryText)
                
                Text(value.isEmpty ? "N/A" : value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.primaryText)
                    .lineLimit(1)
            }
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(AppTheme.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    Color.primary.opacity(0.06),
                    lineWidth: 1
                )
        )
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
