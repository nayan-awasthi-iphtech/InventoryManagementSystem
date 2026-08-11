//
//  AddEditProductView.swift
//  InventoryManagementSystem
//
//  Created by iPHTech 30 on 06/08/26.
//

import SwiftUI
import PhotosUI
import CoreData

struct AddEditProductView: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var productViewModel: ProductViewModel
    
    var productToEdit: Product?
    @State private var photoItem: PhotosPickerItem?

    var hasCategoryAndSupplierData: Bool {
        return !productViewModel.categories.isEmpty && !productViewModel.suppliers.isEmpty
    }
    
    var hasSelectedCategoryAndSupplier: Bool {
        return productViewModel.selectedCategory != nil && productViewModel.selectedSupplier != nil
    }
    
    var body: some View {
        NavigationStack {
            Form {
                if !hasCategoryAndSupplierData && productToEdit == nil {
                    Section {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(.orange)
                                Text("Cannot Add Product")
                                    .font(.headline)
                            }
                            
                            Text("You must create at least one **Category** and one **Supplier** before adding a new product.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                Section("Product Image") {
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            if let data = productViewModel.productImageData, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            } else {
                                Image(systemName: "photo.badge.plus")
                                    .font(.system(size: 40))
                                    .foregroundStyle(.gray)
                                    .frame(width: 100, height: 100)
                                    .background(Color.gray.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            
                            PhotosPicker(selection: $photoItem, matching: .images) {
                                Text(productViewModel.productImageData == nil ? "Select Photo" : "Change Photo")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                            }
                        }
                        Spacer()
                    }
                }
                
                Section("General Info") {
                    TextField("Product Name", text: $productViewModel.productName)
                    TextField("SKU (E.g., PRD-001)", text: $productViewModel.productSKU)
                        .autocapitalization(.allCharacters)
                    TextField("Barcode String", text: $productViewModel.productBarcode)
                }
                
                Section("Classification") {
                    Picker("Category", selection: $productViewModel.selectedCategory) {
                        Text("None").tag(nil as Category?)
                        ForEach(productViewModel.categories, id: \.objectID) { category in
                            Text(category.name ?? "Unnamed Category")
                                .tag(category as Category?)
                        }
                    }
                    
                    Picker("Supplier", selection: $productViewModel.selectedSupplier) {
                        Text("None").tag(nil as Supplier?)
                        ForEach(productViewModel.suppliers, id: \.objectID) { supplier in
                            Text(supplier.name ?? "Unnamed Supplier")
                                .tag(supplier as Supplier?)
                        }
                    }
                }
                
                Section("Stock & Pricing") {
                    HStack {
                        Text("Price ($)")
                        Spacer()
                        TextField("0.00", text: $productViewModel.productPrice)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Quantity")
                        Spacer()
                        TextField("0", text: $productViewModel.productQuantity)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section("Details / Description") {
                    TextField("Enter extra product details...", text: $productViewModel.productDetail)
                        .lineLimit(3...5)
                }
            }
            .navigationTitle(productToEdit == nil ? "Add Product" : "Edit Product")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: photoItem) {
                Task {
                    if let data = try? await photoItem?.loadTransferable(type: Data.self) {
                        productViewModel.productImageData = data
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        productViewModel.clearFields()
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if productToEdit == nil && !hasCategoryAndSupplierData {
                            productViewModel.AlertMessage = "Please create at least one Category and one Supplier first."
                            productViewModel.showAlert = true
                            return
                        }
                        
                        if productToEdit == nil && !hasSelectedCategoryAndSupplier {
                            productViewModel.AlertMessage = "Please select both a Category and a Supplier for the product."
                            productViewModel.showAlert = true
                            return
                        }
                        
                        let success: Bool
                        if let product = productToEdit {
                            success = productViewModel.updateProduct(product)
                        } else {
                            success = productViewModel.Addproducts()
                        }
                        
                        if success {
                            productViewModel.clearFields()
                            dismiss()
                        }
                    }
                    .disabled(productToEdit == nil && !hasCategoryAndSupplierData)
                }
            }
            .onAppear {
                productViewModel.fetchCategories()
                productViewModel.fetchSuppliers()
                
                if let product = productToEdit {
                    productViewModel.populateFields(from: product)
                } else {
                    productViewModel.clearFields()
                }
            }
            .alert("Error", isPresented: $productViewModel.showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(productViewModel.AlertMessage)
            }
        }
    }
}

#Preview {
    AddEditProductView()
        .environmentObject(ProductViewModel())
}
