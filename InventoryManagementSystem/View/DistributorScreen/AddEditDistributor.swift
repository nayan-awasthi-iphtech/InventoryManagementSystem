//
//  AddEditDistributor.swift
//  InventoryManagementSystem
//
//  Created by iPHTech 30 on 13/08/26.
//

import SwiftUI
import PhotosUI
import CoreData

struct AddEditDistributor: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var distributorViewModel: DistributorViewModel
    
    var distributorToEdit: Distributor?
    @State private var photoItem: PhotosPickerItem?
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()
                
                Form {
                    Section("Distributor Image") {
                        HStack {
                            Spacer()
                            VStack(spacing: 8) {
                                if let data = distributorViewModel.distributorImageData, let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                } else {
                                    Image(systemName: "photo.badge.plus")
                                        .font(.system(size: 40))
                                        .foregroundStyle(AppTheme.secondaryText)
                                        .frame(width: 100, height: 100)
                                        .background(AppTheme.secondaryText.opacity(0.1))
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
                        TextField("Distributor Name", text: $distributorViewModel.distributorName)
                        TextField("GST Number (E.g., 22AAAAA0000A1Z5)", text: $distributorViewModel.distributorGstNumber)
                            .textInputAutocapitalization(.characters)
                    }
                    
                    Section("Contact Details") {
                        HStack {
                            Image(systemName: "phone.fill")
                                .foregroundStyle(AppTheme.accent)
                                .frame(width: 24)
                            
                            TextField("Enter 10-digit contact number", text: $distributorViewModel.distributorContact)
                                .keyboardType(.numberPad)
                                .textInputAutocapitalization(.never)
                                .onChange(of: distributorViewModel.distributorContact, clampContactNumber)
                        }
                        
                        HStack {
                            if isContactTooShort {
                                Text("Must be exactly 10 digits")
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.danger)
                            }
                            
                            Spacer()
                            
                            Text(contactCounter)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(contactCounterColor)
                        }
                    }
                    
                    Section("Address") {
                        TextField("Enter address...", text: $distributorViewModel.distributorAddress, axis: .vertical)
                            .lineLimit(3...5)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(distributorToEdit == nil ? "Add Distributor" : "Edit Distributor")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: photoItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        distributorViewModel.distributorImageData = data
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        distributorViewModel.clearFields()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveDistributor()
                    }
                    .fontWeight(.bold)
                }
            }
            .onAppear {
                if let distributor = distributorToEdit {
                    distributorViewModel.populateFields(for: distributor)
                } else {
                    distributorViewModel.clearFields()
                }
            }
            .alert("Error", isPresented: $distributorViewModel.showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(distributorViewModel.alertMsg)
            }
        }
    }
 
    private var photoPickerTitle: String {
        distributorViewModel.distributorImageData == nil ? "Select Photo" : "Change Photo"
    }
    
    private func clampContactNumber() {
        let digitsOnly = distributorViewModel.distributorContact.filter { $0.isNumber }
        let clamped = String(digitsOnly.prefix(10))
        if clamped != distributorViewModel.distributorContact {
            distributorViewModel.distributorContact = clamped
        }
    }
    
    private func saveDistributor() {
        guard distributorViewModel.distributorContact.count == 10 else {
            distributorViewModel.alertMsg = "Please enter a valid 10-digit contact number."
            distributorViewModel.showAlert = true
            return
        }
        
        let success: Bool
        if let distributor = distributorToEdit {
            success = distributorViewModel.updateDistributor(distributor)
        } else {
            success = distributorViewModel.addDistributor()
        }
        
        if success {
            distributorViewModel.clearFields()
            dismiss()
        }
    }
    
    private var isContactTooShort: Bool {
        !distributorViewModel.distributorContact.isEmpty && distributorViewModel.distributorContact.count < 10
    }
    
    private var contactCounter: String {
        "\(distributorViewModel.distributorContact.count)/10"
    }
    
    private var contactCounterColor: Color {
        distributorViewModel.distributorContact.count == 10 ? AppTheme.success : AppTheme.secondaryText
    }
}

#Preview {
    AddEditDistributor()
        .environmentObject(DistributorViewModel())
}
