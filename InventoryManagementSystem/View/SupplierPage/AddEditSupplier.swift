//
//  AddEditSupplier.swift
//  InventoryManagementSystem
//
//  Created by iPHTech 30 on 10/08/26.
//

import SwiftUI
import PhotosUI
import CoreData

struct AddEditSupplier: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var supplierViewModel: SupplierViewModel
    
    var supplierToEdit: Supplier?
    @State private var photoItem: PhotosPickerItem?
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()
                
                Form {
                    Section("Supplier Image") {
                        HStack {
                            Spacer()
                            VStack(spacing: 8) {
                                if let data = supplierViewModel.supplierImageData, let uiImage = UIImage(data: data) {
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
                                    Text(photoPickerTitle)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(AppTheme.accent)
                                }
                            }
                            Spacer()
                        }
                    }
                    
                    Section("General Info") {
                        TextField("Supplier Name", text: $supplierViewModel.supplierName)
                        TextField("GST Number (E.g., 22AAAAA0000A1Z5)", text: $supplierViewModel.supplierGstNumber)
                            .textInputAutocapitalization(.characters)
                    }
                    
                    Section("Contact Details") {
                        HStack {
                            Image(systemName: "phone.fill")
                                .foregroundStyle(AppTheme.accent)
                                .frame(width: 24)
                            
                            TextField("Enter 10-digit contact number", text: $supplierViewModel.supplierContact)
                                .keyboardType(.numberPad)
                                .textInputAutocapitalization(.never)
                                .onChange(of: supplierViewModel.supplierContact, clampContactNumber)
                        }
                        
                        HStack {
                            if isContactTooShort {
                                Text("Must be exactly 10 digits")
                                    .font(.caption)
                                    .foregroundStyle(.red)
                            }
                            
                            Spacer()
                            
                            Text(contactCounter)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(contactCounterColor)
                        }
                    }
                    
                    Section("Address") {
                        TextField("Enter address...", text: $supplierViewModel.supplierAddress, axis: .vertical)
                            .lineLimit(3...5)
                    }
                    
                    Section("Details") {
                        TextField("Enter details...", text: $supplierViewModel.supplierDetails, axis: .vertical)
                            .lineLimit(3...5)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(supplierToEdit == nil ? "Add Supplier" : "Edit Supplier")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: photoItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        supplierViewModel.supplierImageData = data
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        supplierViewModel.clearFields()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveSupplier()
                    }
                    .fontWeight(.bold)
                }
            }
            .onAppear {
                if let supplier = supplierToEdit {
                    supplierViewModel.populateFields(for: supplier)
                } else {
                    supplierViewModel.clearFields()
                }
            }
            .alert("Error", isPresented: $supplierViewModel.showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(supplierViewModel.alertMsg)
            }
        }
    }
 
    private var photoPickerTitle: String {
        supplierViewModel.supplierImageData == nil ? "Select Photo" : "Change Photo"
    }
    
    private func clampContactNumber() {
        let digitsOnly = supplierViewModel.supplierContact.filter { $0.isNumber }
        let clamped = String(digitsOnly.prefix(10))
        if clamped != supplierViewModel.supplierContact {
            supplierViewModel.supplierContact = clamped
        }
    }
    
    private func saveSupplier() {
        guard supplierViewModel.supplierContact.count == 10 else {
            supplierViewModel.alertMsg = "Please enter a valid 10-digit contact number."
            supplierViewModel.showAlert = true
            return
        }
        
        let success: Bool
        if let supplier = supplierToEdit {
            success = supplierViewModel.updateSupplier(supplier)
        } else {
            success = supplierViewModel.addSupplier()
        }
        
        if success {
            supplierViewModel.clearFields()
            dismiss()
        }
    }
    
    private var isContactTooShort: Bool {
        !supplierViewModel.supplierContact.isEmpty && supplierViewModel.supplierContact.count < 10
    }
    
    private var contactCounter: String {
        "\(supplierViewModel.supplierContact.count)/10"
    }
    
    private var contactCounterColor: Color {
        supplierViewModel.supplierContact.count == 10 ? .green : .secondary
    }
}

#Preview {
    AddEditSupplier()
        .environmentObject(SupplierViewModel())
}
