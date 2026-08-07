//
//  AddEditProductView.swift
//  InventoryManagementSystem
//
//  Created by iPHTech 30 on 06/08/26.
//

import SwiftUI
import PhotosUI

struct AddEditProductView: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var productViewModel: ProductViewModel
    
    var productToEdit: Product?
    @State private var photoItem: PhotosPickerItem?
    
    var body: some View {
        NavigationStack{
            Form {
                Section("Product Image"){
                    HStack{
                        Spacer()
                        VStack(spacing:8){
                            if let data = productViewModel.productImageData, let uiImage = UIImage(data: data){
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width:100, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            } else {
                                Image(systemName: "photo.badge.plus")
                                    .font(.system(size: 40))
                                    .foregroundStyle(.gray)
                                    .frame(width: 100, height: 100)
                                    .background(Color.gray.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            
                            PhotosPicker(selection: $photoItem, matching: .images){
                                Text(productViewModel.productImageData == nil ? "Select Photo": "Change Photo")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                            }
                        }
                        Spacer()
                    }
                }
                
                Section("General Info"){
                    TextField("Product Name", text: $productViewModel.productName)
                    TextField("SKU (E.g., PRD-001)", text: $productViewModel.productSKU)
                        .autocapitalization(.allCharacters)
                    TextField("Barcode String", text: $productViewModel.productBarcode)
                }
                
                Section("Stock & Pricing"){
                    HStack{
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
                
                Section("Details / Description"){
                    TextField("Enter extra product details...", text: $productViewModel.productDetail)
                        .lineLimit(3...5)
                }
            }
            .navigationTitle(productToEdit == nil ? "Add Product": "Edit Product")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: photoItem){
                Task{
                    if let data = try? await photoItem?.loadTransferable(type: Data.self){
                        productViewModel.productImageData = data
                    }
                }
            }
            .toolbar{
                ToolbarItem(placement: .cancellationAction){
                    Button("Cancel"){
                        productViewModel.clearFields()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction){
                    Button("Save"){
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
                }
            }
            .onAppear {
                if let product = productToEdit{
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
}
