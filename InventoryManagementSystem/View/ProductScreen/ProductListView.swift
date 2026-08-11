//
//  ProductListView.swift
//  InventoryManagementSystem
//
//  Created by iPHTech 30 on 06/08/26.
//

import SwiftUI
import CoreData

struct ProductListView: View {
    
    @StateObject var productViewModel = ProductViewModel()
    
    @State private var showAddSheet: Bool = false
    @State private var productToDelete: Product?
    @State private var showDeleteAlert: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                AppTheme.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ZStack {
                        Text("Products")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        HStack {
                            Spacer()
                            Button {
                                showAddSheet = true
                            } label: {
                                Image(systemName: "plus")
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(.white)
                                    .frame(width: 40, height: 40)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.top, 8)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.gray)
                        
                        TextField("Search name, SKU or barcode", text: $productViewModel.searchText)
                            .autocorrectionDisabled()
                        
                        if !productViewModel.searchText.isEmpty {
                            Button {
                                productViewModel.searchText = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.gray)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 44)
                    .background(Color.white)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.gray.opacity(0.2), lineWidth: 1))
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    
                    Group {
                        if productViewModel.products.isEmpty {
                            ContentUnavailableView(
                                productViewModel.searchText.isEmpty ? "No Products" : "No Results",
                                systemImage: productViewModel.searchText.isEmpty ? "cube.box" : "magnifyingglass",
                                description: Text(productViewModel.searchText.isEmpty ? "Tap + to add your first product." : "No products match your search.")
                            )
                        } else {
                            List {
                                ForEach(productViewModel.products) { product in
                                    NavigationLink(destination: ProductDetailPage(product: product).environmentObject(productViewModel)){
                                        ProductRow(product: product)
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button(role: .destructive) {
                                            productToDelete = product
                                            showDeleteAlert = true
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                            .scrollContentBackground(.hidden)
                        }
                    }
                }
                .sheet(isPresented: $showAddSheet) {
                    AddEditProductView()
                        .environmentObject(productViewModel)
                }
                .onChange(of: productViewModel.searchText) {
                    productViewModel.fetchProducts()
                }
                .alert("Delete Product", isPresented: $showDeleteAlert) {
                    Button("Delete", role: .destructive) {
                        if let product = productToDelete {
                            productViewModel.deleteProduct(product)
                        }
                        productToDelete = nil
                    }
                    Button("Cancel", role: .cancel) {
                        productToDelete = nil
                    }
                } message: {
                    Text("Are you sure you want to delete '\(productToDelete?.name ?? "this product")'? This action cannot be undone.")
                }
                .onAppear{
                    productViewModel.fetchProducts()
                }
            }
        }
    }
    
    private struct ProductRow: View {
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
                .frame(width: 48, height: 48)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.name ?? "Unnamed Product")
                        .font(.headline)
                        .lineLimit(1)
                    
                    Text(product.product_category?.name ?? "No Category")
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
            .padding(.vertical, 4)
        }
    }
}

#Preview {
    ProductListView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
