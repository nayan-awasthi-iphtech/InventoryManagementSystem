//
//  EditAdminProfileView.swift
//  InventoryManagementSystem
//
//  Created by iPHTech 30 on 14/08/26.
//

import SwiftUI

struct EditAdminProfileView: View {
    
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var profileViewModel: AdminProfileViewModel
    
    @State private var isPasswordVisible = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()
                
                Form {
                    Section("General Info") {
                        TextField("Name", text: $profileViewModel.name)
                            .textInputAutocapitalization(.words)
                        
                        TextField("Email", text: $profileViewModel.email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                        
                        TextField("Contact Number", text: $profileViewModel.contact)
                            .keyboardType(.numberPad)
                            .onChange(of: profileViewModel.contact) {
                                let filtered = profileViewModel.contact.filter { $0.isNumber }
                                if filtered.count > 10 {
                                    profileViewModel.contact = String(filtered.prefix(10))
                                } else if profileViewModel.contact != filtered {
                                    profileViewModel.contact = filtered
                                }
                            }
                    }
                    
                    Section("Change Password (Optional)") {
                        HStack {
                            if isPasswordVisible {
                                TextField("New password", text: $profileViewModel.password)
                            } else {
                                SecureField("New password", text: $profileViewModel.password)
                            }
                            
                            Button {
                                isPasswordVisible.toggle()
                            } label: {
                                Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                    .foregroundStyle(AppTheme.secondaryText)
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if profileViewModel.updateProfile() {
                            dismiss()
                        }
                    }
                    .fontWeight(.bold)
                }
            }
            .onAppear {
                profileViewModel.password = ""
            }
            .alert("Error", isPresented: $profileViewModel.showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(profileViewModel.alertMessage)
            }
        }
    }
}

#Preview {
    EditAdminProfileView(profileViewModel: AdminProfileViewModel())
}