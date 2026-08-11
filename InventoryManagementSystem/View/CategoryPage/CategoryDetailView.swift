//
//  CategoryDetailView.swift
//  InventoryManagementSystem
//
//  Created by iPHTech 30 on 07/08/26.
//

import SwiftUI
import CoreData

struct CategoryDetailView: View {
    
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var category: Category
    @StateObject private var viewModel = CategoryViewModel()
    
    @State private var showEditSheet = false
    @State private var showDeleteAlert = false
    
    private var products: [Product] {
        (category.category_product as? Set<Product>)?
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
                    
                    productsSection
                }
                .padding()
            }
        }
        .navigationTitle("Category")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
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
        .sheet(isPresented: $showEditSheet) {
            AddEditCategoryView(categoryToEdit: category)
                .environmentObject(viewModel)
        }
        .alert("Delete Category", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                if viewModel.deleteCategory(category) {
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete '\(category.name ?? "this category")'? This action cannot be undone.")
        }
    }
    
    private var header: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.blue.opacity(0.12))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "folder.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(.blue)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(category.name ?? "Unnamed Category")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("\(products.count) Products")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            CategoryStatCard(
                icon: "cube.box.fill",
                color: .blue,
                value: "\(products.count)",
                label: "Total Products"
            )
            CategoryStatCard(
                icon: "shippingbox.fill",
                color: .orange,
                value: "\(totalStock)",
                label: "Total Stock"
            )
            CategoryStatCard(
                icon: "exclamationmark.triangle.fill",
                color: .yellow,
                value: "\(lowStockCount)",
                label: "Low Stock"
            )
            CategoryStatCard(
                icon: "xmark.octagon.fill",
                color: .red,
                value: "\(outOfStockCount)",
                label: "Out of Stock"
            )
        }
    }
    
    private var productsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "cube.box")
                    .font(.headline)
                    .foregroundStyle(.blue)
                Text("Products in this Category")
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
                    Text("This category has no products yet.")
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
                            CategoryProductRow(product: product)
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

private struct CategoryStatCard: View {
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
                .foregroundStyle(.primary)
            
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private struct CategoryProductRow: View {
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
                        .fill(Color.blue.opacity(0.15))
                        .overlay(
                            Image(systemName: "cube.fill")
                                .foregroundStyle(.blue)
                        )
                }
            }
            .frame(width: 44, height: 44)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name ?? "Unnamed Product")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                
                Text(product.sku?.isEmpty == false ? "SKU: \(product.sku!)" : "No SKU")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(product.price.formatted(.currency(code: "INR")))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text("Qty: \(product.quantity)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(product.quantity > 0 ? .green : .red)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    
    let sampleCategory = Category(context: context)
    sampleCategory.name = "Electronics"
    
    let sampleProduct = Product(context: context)
    sampleProduct.name = "Sample Headphones"
    sampleProduct.price = 2999.00
    sampleProduct.quantity = 10
    sampleProduct.product_category = sampleCategory
    
    return NavigationStack {
        CategoryDetailView(category: sampleCategory)
    }
}
