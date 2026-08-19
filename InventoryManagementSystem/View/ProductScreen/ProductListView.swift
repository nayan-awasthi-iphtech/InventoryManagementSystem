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
    @State private var showScannerSheet: Bool = false
    @State private var productToDelete: Product?
    @State private var showDeleteAlert: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                AppTheme.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Inventora")
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundStyle(AppTheme.accent)
                            
                            Text("Products")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundStyle(AppTheme.primaryText)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 12) {
                            Button {
                                showScannerSheet = true
                            } label: {
                                Image(systemName: "barcode.viewfinder")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(AppTheme.accent)
                                    .frame(width: 44, height: 44)
                                    .background(AppTheme.accent.opacity(0.12))
                                    .clipShape(Circle())
                            }
                            
                            Button {
                                showAddSheet = true
                            } label: {
                                Image(systemName: "plus")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .frame(width: 44, height: 44)
                                    .background(AppTheme.accent)
                                    .clipShape(Circle())
                                    .shadow(color: AppTheme.accent.opacity(0.3), radius: 6, y: 3)
                            }
                            .padding(.top, 4)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 4)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.secondaryText)
                        
                        TextField("Search name, SKU or barcode", text: $productViewModel.searchText)
                            .autocorrectionDisabled()
                        
                        if !productViewModel.searchText.isEmpty {
                            Button {
                                productViewModel.searchText = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(AppTheme.secondaryText)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(AppTheme.cardBackground)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 6)
                    
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
                                            .zIndex(0)
                                            .padding(10)
                                            .background(
                                                RoundedRectangle(cornerRadius: 14)
                                                    .fill(AppTheme.cardBackground)
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 14)
                                                    .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                                            )
                                    }
                                    .listRowBackground(Color.clear)
                                    .listRowInsets(EdgeInsets(top: 2, leading: 16, bottom: 4, trailing: 16))
                                    .listRowSeparator(.hidden)
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
                            .contentMargins(.top, 6, for: .scrollContent)
                        }
                    }
                }
                .sheet(isPresented: $showAddSheet) {
                    AddEditProductView()
                        .environmentObject(productViewModel)
                }
                .sheet(isPresented: $showScannerSheet) {
                    NavigationStack {
                        BarcodeScannerView()
                    }
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
                            .fill(AppTheme.accent.opacity(0.15))
                            .overlay(
                                Image(systemName: "cube.fill")
                                    .foregroundStyle(AppTheme.accent)
                            )
                    }
                }
                .frame(width: 48, height: 48)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.name ?? "Unnamed Product")
                        .font(.headline)
                        .foregroundStyle(AppTheme.primaryText)
                        .lineLimit(1)
                    
                    Text(product.product_category?.name ?? "No Category")
                        .font(.caption)
                        .foregroundStyle(AppTheme.secondaryText)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(product.price.formatted(.currency(code: "INR")))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(AppTheme.primaryText)
                    
                    Text("Qty: \(product.quantity)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(product.quantity > 0 ? AppTheme.success : AppTheme.danger)
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
