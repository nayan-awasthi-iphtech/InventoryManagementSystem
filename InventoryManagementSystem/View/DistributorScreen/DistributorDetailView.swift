//
//  DistributorDetailView.swift
//  InventoryManagementSystem
//
//  Created by iPHTech 30 on 13/08/26.
//

import SwiftUI
import CoreData

struct DistributorDetailView: View {
    
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var distributor: Distributor
    @EnvironmentObject var distributorViewModel: DistributorViewModel
    
    @State private var showEditSheet = false
    @State private var showDeleteAlert = false
    
    private var product: Product? {
        distributor.distributor_product
    }
    
    private var category: Category? {
        distributor.distributor_category
    }
    
    private var totalStock: Int {
        (distributor.distributor_order as? Set<Order>)?
            .filter { ($0.status ?? "").lowercased() == "delivered" }
            .reduce(0) { total, order in
                let items = (order.order_orderItem as? Set<OrderItem>) ?? []
                return total + items.reduce(0) { $0 + Int($1.quantity) }
            } ?? 0
    }
    
    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    
                    header
                    
                    statsGrid
                    
                    infoSection
                    
                    productSection
                }
                .padding()
            }
        }
        .navigationTitle("Distributor")
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
            AddEditDistributor(distributorToEdit: distributor)
                .environmentObject(distributorViewModel)
        }
        .alert("Delete Distributor", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                if distributorViewModel.deleteDistributor(distributor) {
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete '\(distributor.name ?? "this distributor")'? This action cannot be undone.")
        }
    }
    
    private var header: some View {
        VStack(spacing: 16) {
            if let data = distributor.imageData, let image = UIImage(data: data) {
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
                    
                    Image(systemName: "truck.box.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(AppTheme.accent)
                }
            }
            
            VStack(spacing: 6) {
                Text(distributor.name ?? "Unnamed Distributor")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.primaryText)
                    .multilineTextAlignment(.center)
                
                Text(product == nil ? "No product assigned" : "Supplies \(product?.name ?? "a product")")
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
            DistributorStatCard(
                icon: "cube.box.fill",
                color: AppTheme.accent,
                value: "\(product == nil ? 0 : 1)",
                label: "Total Products"
            )
            DistributorStatCard(
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
                Image(systemName: "info.circle.fill")
                    .font(.headline)
                    .foregroundStyle(AppTheme.accent)
                Text("Distributor Information")
                    .font(.headline)
                    .foregroundStyle(AppTheme.primaryText)
            }
            
            Divider()
            
            infoRow(
                icon: "folder.fill",
                label: "Category",
                value: category?.name ?? "N/A"
            )
            infoRow(
                icon: "building.2",
                label: "GST Number",
                value: distributor.gstNumber?.isEmpty == false ? distributor.gstNumber! : "N/A"
            )
            infoRow(
                icon: "phone.fill",
                label: "Contact",
                value: distributor.contact?.isEmpty == false ? distributor.contact! : "N/A"
            )
            infoRow(
                icon: "mappin.and.ellipse",
                label: "Address",
                value: distributor.address?.isEmpty == false ? distributor.address! : "N/A"
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
    
    private var productSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "cube.box")
                    .font(.headline)
                    .foregroundStyle(AppTheme.accent)
                Text("Product Supplied")
                    .font(.headline)
                    .foregroundStyle(AppTheme.primaryText)
            }
            
            Divider()
            
            if let product = product {
                NavigationLink {
                    ProductDetailPage(product: product)
                } label: {
                    DistributorProductRow(product: product)
                }
                .buttonStyle(.plain)
            } else {
                VStack(spacing: 10) {
                    Image(systemName: "cube.box")
                        .font(.system(size: 40))
                        .foregroundStyle(AppTheme.secondaryText.opacity(0.5))
                    Text("No Product")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(AppTheme.secondaryText)
                    Text("This distributor has not been assigned any product yet.")
                        .font(.caption)
                        .foregroundStyle(AppTheme.secondaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            }
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
}

private struct DistributorStatCard: View {
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

private struct DistributorProductRow: View {
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

#Preview {
    let context = PersistenceController.preview.container.viewContext
    
    let sampleCategory = Category(context: context)
    sampleCategory.name = "Electronics"
    
    let sampleDistributor = Distributor(context: context)
    sampleDistributor.name = "Prime Distributors"
    sampleDistributor.gstNumber = "22AAAAA0000A1Z5"
    sampleDistributor.contact = "9876543210"
    sampleDistributor.address = "Mumbai"
    sampleDistributor.distributor_category = sampleCategory
    
    let sampleProduct = Product(context: context)
    sampleProduct.name = "Sample Headphones"
    sampleProduct.price = 2999.00
    sampleProduct.quantity = 10
    sampleProduct.product_category = sampleCategory
    sampleProduct.product_distributor = sampleDistributor
    
    return NavigationStack {
        DistributorDetailView(distributor: sampleDistributor)
    }
}
