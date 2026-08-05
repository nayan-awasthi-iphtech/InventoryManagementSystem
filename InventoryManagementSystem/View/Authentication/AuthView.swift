//
//  AuthView.swift
//  InventoryManagementSystem
//
//  Created by iPHTech 30 on 05/08/26.
//

import SwiftUI

struct AuthView: View {
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var contactNo: String = ""
    @State private var name: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var isLogin: Bool = true
    @State private var isLoggedIn: Bool = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                Color(uiColor: .systemRed).opacity(0.3)
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        
                        ZStack {
                            
                            RoundedRectangle(cornerRadius: 32)
                                .fill(LinearGradient(colors: [.orange.opacity(0.15), .blue.opacity(0.08)], startPoint: .top, endPoint: .bottom))
                                .frame(height: 220)
                            
                            VStack {
                                Image(systemName: isLogin ? "box.truck.badge.clock.fill" : "building.2.crop.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .foregroundStyle(.blue)
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.top, 10)
                        
                        VStack(spacing: 6) {
                            Text(isLogin ? "Login to Access Your": "Register to access")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.brown)
                            
                            Text(isLogin ? "Inventory Dashboard" : "Inventory and Stocks")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.blue)
                        }
                        .padding(.top, 8)
                        
                        VStack(spacing: 14) {
                            
                            if !isLogin {
                                HStack(spacing: 12) {
                                    Image(systemName: "person.fill")
                                        .foregroundStyle(.gray)
                                    TextField("Enter your name", text: $name)
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
                                TextField("Enter your email", text: $email)
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
                                
                                if isPasswordVisible {
                                    TextField("Enter your password", text: $password)
                                } else {
                                    SecureField("Enter your password", text: $password)
                                }
                                
                                Button {
                                    isPasswordVisible.toggle()
                                } label: {
                                    Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                        .foregroundStyle(.gray)
                                }
                            }
                            .padding(.horizontal, 16)
                            .frame(height: 50)
                            .background(Color.white.opacity(0.6))
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Color.gray.opacity(0.2), lineWidth: 1))
                            
                            if !isLogin {
                                HStack(spacing: 12) {
                                    Image(systemName: "phone.fill")
                                        .foregroundStyle(.gray)
                                    TextField("Enter your Contact Number", text: $contactNo)
                                        .keyboardType(.emailAddress)
                                        .textInputAutocapitalization(.never)
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
                            if isLogin {
                                isLoggedIn = true
                            } else {
                                // todo
                            }
                        } label: {
                            Text(isLogin ? "Login" : "Register")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.red.opacity(0.7))
                                .clipShape(Capsule())
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 6)
                        
                        
                        HStack(spacing: 4) {
                            Text(isLogin ? "Don't have an account?" : "Already have an account?")
                                .font(.caption)
                                .foregroundStyle(.gray)
                            
                            Button {
                                withAnimation {
                                    isLogin.toggle()
                                }
                            } label: {
                                Text(isLogin ? "Create an account" :  "Please Login")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.blue)
                            }
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 20)
                    }
                }
                .navigationDestination(isPresented: $isLoggedIn){
                    DashboardScreenView()
                }
            }
        }
    }
}

#Preview {
    AuthView()
}

