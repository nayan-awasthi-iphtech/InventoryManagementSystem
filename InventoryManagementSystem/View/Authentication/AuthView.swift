//
//  AuthView.swift
//  InventoryManagementSystem
//
//  Created by iPHTech 30 on 05/08/26.
//

import SwiftUI

struct AuthView: View {
    
    @StateObject var authViewModel: AuthViewModel
    @ObservedObject private var sessionManager = SessionManager.shared
    
    init(initialMode: Bool = true) {
        _authViewModel = StateObject(wrappedValue: AuthViewModel(isLogin: initialMode))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                Color(uiColor: .systemTeal).opacity(0.2)
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        
                        ZStack {
                            
                            RoundedRectangle(cornerRadius: 32)
                                .fill(LinearGradient(colors: [.orange.opacity(0.15), .blue.opacity(0.08)], startPoint: .top, endPoint: .bottom))
                                .frame(height: 220)
                            
                            VStack {
                                Image(systemName: authViewModel.isLogin ? "box.truck.badge.clock.fill" : "building.2.crop.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .foregroundStyle(.blue)
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.top, 10)
                        
                        VStack(spacing: 6) {
                            Text(authViewModel.isLogin ? "Login to Access Your": "Register to access")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.brown)
                            
                            Text(authViewModel.isLogin ? "Inventory Dashboard" : "Inventory and Stocks")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.blue)
                        }
                        .padding(.top, 8)
                        
                        VStack(spacing: 14) {
                            
                            if !authViewModel.isLogin {
                                HStack(spacing: 12) {
                                    Image(systemName: "person.fill")
                                        .foregroundStyle(.gray)
                                    TextField("Enter your name", text: $authViewModel.name)
                                        .keyboardType(.emailAddress)
                                        .textInputAutocapitalization(.never)
                                }
                                .padding(.horizontal, 16)
                                .frame(height: 50)
                                .background(Color.white.opacity(0.6))
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(Color.gray.opacity(0.2), lineWidth: 1))
                            }
                            
                            HStack(spacing: 12) {
                                Image(systemName: "envelope")
                                    .foregroundStyle(.gray)
                                TextField("Enter your email", text: $authViewModel.email)
                                    .keyboardType(.emailAddress)
                                    .textInputAutocapitalization(.never)
                            }
                            .padding(.horizontal, 16)
                            .frame(height: 50)
                            .background(Color.white.opacity(0.6))
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Color.gray.opacity(0.2), lineWidth: 1))
                            
                            HStack(spacing: 12) {
                                Image(systemName: "lock")
                                    .foregroundStyle(.gray)
                                
                                if authViewModel.isPasswordVisible {
                                    TextField("Enter your password", text: $authViewModel.password)
                                } else {
                                    SecureField("Enter your password", text: $authViewModel.password)
                                }
                                
                                Button {
                                    authViewModel.isPasswordVisible.toggle()
                                } label: {
                                    Image(systemName: authViewModel.isPasswordVisible ? "eye.slash" : "eye")
                                        .foregroundStyle(.gray)
                                }
                            }
                            .padding(.horizontal, 16)
                            .frame(height: 50)
                            .background(Color.white.opacity(0.6))
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Color.gray.opacity(0.2), lineWidth: 1))
                            
                            if !authViewModel.isLogin {
                                HStack(spacing: 12) {
                                    Image(systemName: "phone.fill")
                                        .foregroundStyle(.gray)
                                    TextField("Enter your Contact Number", text: $authViewModel.contactNo)
                                        .keyboardType(.numberPad)
                                        .textInputAutocapitalization(.never)
                                        .onChange(of: authViewModel.contactNo) {
                                            let filtered = authViewModel.contactNo.filter { $0.isNumber }
                                                if filtered.count > 10 {
                                                    authViewModel.contactNo = String(filtered.prefix(10))
                                                } else if authViewModel.contactNo != filtered {
                                                    authViewModel.contactNo = filtered
                                                }
                                            }
                                }
                                .padding(.horizontal, 16)
                                .frame(height: 50)
                                .background(Color.white.opacity(0.6))
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(Color.gray.opacity(0.2), lineWidth: 1))
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        Button {
                            authViewModel.handleAuth()
                        } label: {
                            Text(authViewModel.isLogin ? "Login" : "Register")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.blue.opacity(0.7))
                                .clipShape(Capsule())
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 6)
                        
                        
                        HStack(spacing: 4) {
                            Text(authViewModel.isLogin ? "Don't have an account?" : "Already have an account?")
                                .font(.caption)
                                .foregroundStyle(.gray)
                            
                            Button {
                                withAnimation {
                                    authViewModel.isLogin.toggle()
                                }
                            } label: {
                                Text(authViewModel.isLogin ? "Create an account" :  "Please Login")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.blue)
                            }
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 20)
                    }
                }
                .navigationDestination(isPresented: $sessionManager.isLoggedIn){
                    RootTabView()
                        .onAppear{
                            authViewModel.clearFields()
                        }
                }
            }
            .alert("Missing Information", isPresented: $authViewModel.showAlert){
                Button("Cancel", role:.cancel) {}
            } message: {
                Text(authViewModel.alertMessage)
            }
        }
    }
}

#Preview {
    AuthView()
}

