//
//  SupplierDetailView.swift
//  InventoryManagementSystem
//
//  Created by iPHTech 30 on 10/08/26.
//

import SwiftUI
import CoreData

struct SupplierDetailView: View {
    
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var supplier: Supplier
    @StateObject private var supplierViewModel = SupplierViewModel()
    
    @State private var showEditSheet = false
    @State private var showDeleteAlert = false
    
    private var products: [Product] {
        (supplier.supplier_product as? Set<Product>)?
            .sorted { ($0.name ?? "") < ($1.name ?? "") } ?? []
    }
    
    private var categories: [Category] {
        (supplier.supplier_category as? Set<Category>)?
            .sorted { ($0.name ?? "") < ($1.name ?? "") } ?? []
    }
    
    private var totalStock: Int {
        products.reduce(0) { $0 + Int($1.quantity) }
    }
    
    private var lowStockCount: Int {
        products.filter { $0.quantity > 0 && $0.quantity < 5 }.count
    }
    
    private var outOfStockCount: Int {
        products.filter { $0.quantity == 0 }.count
    }
    
    var body: some View {
        ZStack{
            AppTheme.background
                .ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    
                    header
                    
                    statsGrid
                    
                    infoSection
                    
                    descriptionSection
                    
                    ProductsSection(supplier: supplier)
                }
                .padding()
            }
        }
        .navigationTitle("Supplier")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    showEditSheet = true
                } label: {
                    Image(systemName: "square.and.pencil")
                        .foregroundStyle(AppTheme.accent)
                }
                
                Button(role: .destructive) {
                    showDeleteAlert = true
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(AppTheme.danger)
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            AddEditSupplier(supplierToEdit: supplier)
                .environmentObject(supplierViewModel)
        }
        .alert("Delete Supplier", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                if supplierViewModel.deleteSupplier(supplier) {
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete '\(supplier.name ?? "this supplier")'? This action cannot be undone.")
        }
    }
    
    private var header: some View {
        VStack(spacing: 16) {
            if let data = supplier.imageData, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(AppTheme.accent.opacity(0.12))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "shippingbox.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(AppTheme.accent)
                }
            }
            
            VStack(spacing: 6) {
                Text(supplier.name ?? "Unnamed Supplier")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.primaryText)
                    .multilineTextAlignment(.center)
                
                Text("\(products.count) Products Supplied")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.secondaryText)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(AppTheme.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
    }
    
    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            SupplierStatCard(
                icon: "cube.box.fill",
                color: AppTheme.accent,
                value: "\(products.count)",
                label: "Total Products"
            )
            SupplierStatCard(
                icon: "shippingbox.fill",
                color: AppTheme.warning,
                value: "\(totalStock)",
                label: "Total Stock"
            )
        }
    }
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "person.crop.circle.badge.plus")
                    .font(.headline)
                    .foregroundStyle(AppTheme.accent)
                Text("Supplier Information")
                    .font(.headline)
                    .foregroundStyle(AppTheme.primaryText)
            }
            
            Divider()
        
            infoRow(
                icon: "building.2",
                label: "GST Number",
                value: supplier.gstNumber?.isEmpty == false ? supplier.gstNumber! : "N/A"
            )
            infoRow(
                icon: "phone.fill",
                label: "Contact",
                value: supplier.contact?.isEmpty == false ? supplier.contact! : "N/A"
            )
            infoRow(
                icon: "mappin.and.ellipse",
                label: "Address",
                value: supplier.address?.isEmpty == false ? supplier.address! : "N/A"
            )
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(AppTheme.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
    }
    
    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundStyle(AppTheme.secondaryText)
                    .frame(width: 20)
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.secondaryText)
            }
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(AppTheme.primaryText)
                .multilineTextAlignment(.trailing)
        }
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "doc.text")
                    .foregroundStyle(AppTheme.accent)
                Text("Description")
                    .font(.headline)
                    .foregroundStyle(AppTheme.primaryText)
            }
            
            Divider()
            
            Text(supplier.supplierDetail?.isEmpty == false ? supplier.supplierDetail! : "No detail for this supplier is available")
                .font(.subheadline)
                .foregroundStyle(AppTheme.secondaryText)
                .lineSpacing(4)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
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

#Preview {
    let context = PersistenceController.preview.container.viewContext
    
    let sampleCategory = Category(context: context)
    sampleCategory.name = "Electronics"
    
    let sampleSupplier = Supplier(context: context)
    sampleSupplier.name = "Tech Distributors"
    sampleSupplier.gstNumber = "22AAAAA0000A1Z5"
    sampleSupplier.contact = "9876543210"
    sampleSupplier.address = "Mumbai"
    sampleSupplier.addToSupplier_category(sampleCategory)
    
    let sampleProduct = Product(context: context)
    sampleProduct.name = "Sample Headphones"
    sampleProduct.price = 2999.00
    sampleProduct.quantity = 10
    sampleProduct.product_category = sampleCategory
    sampleProduct.product_Supplier = sampleSupplier
    
    return NavigationStack {
        SupplierDetailView(supplier: sampleSupplier)
    }
}
