//
//  AdminProfileView.swift
//  InventoryManagementSystem
//
//  Created by iPHTech 30 on 14/08/26.
//

import SwiftUI
import PhotosUI

struct AdminProfileView: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var profileViewModel = AdminProfileViewModel()
    
    @State private var showEditSheet = false
    @State private var photoItem: PhotosPickerItem?
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    viewContent
                        .padding(16)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showEditSheet = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .foregroundStyle(AppTheme.accent)
                    }
                }
            }
            .sheet(isPresented: $showEditSheet) {
                EditAdminProfileView(profileViewModel: profileViewModel)
            }
            .onChange(of: photoItem) {
                Task {
                    if let data = try? await photoItem?.loadTransferable(type: Data.self) {
                        profileViewModel.saveProfileImage(data)
                    }
                }
            }
            .alert("Profile Photo Updated", isPresented: $profileViewModel.showSuccessAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Your profile photo has been saved successfully.")
            }
        }
    }
    
    private var viewContent: some View {
        
        VStack(spacing: 20){
                VStack(spacing: 16) {
                
                VStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [AppTheme.accent.opacity(0.18), AppTheme.warning.opacity(0.18)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 116, height: 116)
                        
                        avatarContent
                            .frame(width: 104, height: 104)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            colors: [AppTheme.accent.opacity(0.4), AppTheme.warning.opacity(0.8)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 3
                                    )
                            )
                            .shadow(color: .black.opacity(0.12), radius: 8, y: 4)
                        
                        PhotosPicker(selection: $photoItem, matching: .images) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 34, height: 34)
                                .background(AppTheme.accent)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
                        }
                        .offset(x: 40, y: 40)
                    }
                    
                    VStack(spacing: 4) {
                        Text(profileViewModel.name.isEmpty ? "Admin" : profileViewModel.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(AppTheme.primaryText)
                        
                        Text(profileViewModel.email.isEmpty ? "No email" : profileViewModel.email)
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.secondaryText)
                    }
                    
                    if !profileViewModel.memberSince.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: "calendar")
                                .font(.caption)
                            Text(profileViewModel.memberSince)
                                .font(.caption)
                        }
                        .foregroundStyle(AppTheme.secondaryText)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                
                VStack(spacing: 0) {
                    profileInfoRow(icon: "person.fill", label: "Name", value: profileViewModel.name.isEmpty ? "—" : profileViewModel.name)
                    Divider().padding(.leading, 48)
                    profileInfoRow(icon: "envelope.fill", label: "Email", value: profileViewModel.email.isEmpty ? "—" : profileViewModel.email)
                    Divider().padding(.leading, 48)
                    profileInfoRow(icon: "phone.fill", label: "Contact", value: profileViewModel.contact.isEmpty ? "—" : profileViewModel.contact)
                    Divider().padding(.leading, 48)
                    profileInfoRow(
                        icon: "lock.fill",
                        label: "Password",
                        value: profileViewModel.password.isEmpty ? "—" : String(repeating: "•", count: 8)
                    )
                }
                .padding(.horizontal, 16)
                
            }
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.cardBackground, AppTheme.success.opacity(0.08)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.primary.opacity(0.06), lineWidth: 1)
            )
            
            Button {
                SessionManager.shared.logout()
                dismiss()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.headline)
                    Text("Logout")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundStyle(AppTheme.danger)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(AppTheme.danger.opacity(0.12))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(AppTheme.danger.opacity(0.3), lineWidth: 1))
            }
        }
    }
    
    private func profileInfoRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(AppTheme.accent)
                .frame(width: 28, height: 28)
                .background(AppTheme.accent.opacity(0.12))
                .clipShape(Circle())
            
            Text(label)
                .font(.subheadline)
                .foregroundStyle(AppTheme.secondaryText)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(AppTheme.primaryText)
                .lineLimit(1)
        }
        .padding(.vertical, 12)
    }
    
    @ViewBuilder
    private var avatarContent: some View {
        if let data = profileViewModel.imageData, let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppTheme.accent.opacity(0.12))
                
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .padding(26)
                    .foregroundStyle(AppTheme.accent)
            }
        }
    }
}

#Preview {
    AdminProfileView()
}
