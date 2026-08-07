//
//  LandingPageView.swift
//  InventoryManagementSystem
//
//  Created by iPHTech 30 on 07/08/26.
//

import SwiftUI

struct LandingPageView: View {
    
    @State private var showLogin = false
    @State private var showSignup = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(white: 0.2), Color(white: 0.06)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        
                        Spacer(minLength: 20)
                        
                        VStack(spacing: 20) {
                            ZStack {
                                Circle()
                                    .fill(Color.orange.opacity(0.35))
                                    .frame(width: 190, height: 190)
                                    .blur(radius: 30)
                                
                                Image("splashimg")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 170, height: 170)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                LinearGradient(
                                                    colors: [.red.opacity(0.4), .orange.opacity(0.8)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 3
                                            )
                                    )
                                    .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 8)
                            }
                            
                            VStack(spacing: 8) {
                                Text("Inventora")
                                    .font(.system(size: 36, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                                    .shadow(color: .white.opacity(0.15), radius: 6)
                                
                                Text("Precision in Every Count.")
                                    .font(.title3)
                                    .fontDesign(.serif)
                                    .italic()
                                    .foregroundStyle(Color.orange.opacity(0.9))
                            }
                            
                            Text("A smart inventory management solution to track products, manage stock levels and grow your business effortlessly.")
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(Color.gray.opacity(0.9))
                                .padding(.horizontal, 30)
                        }
                        
                        VStack(spacing: 14) {
                            FeatureRow(
                                icon: "cube.box.fill",
                                color: .blue,
                                title: "Product Management",
                                subtitle: "Add, edit and organize your products with ease."
                            )
                            FeatureRow(
                                icon: "chart.line.uptrend.xyaxis",
                                color: .orange,
                                title: "Smart Dashboard",
                                subtitle: "Track stock levels and revenue at a glance."
                            )
                        }
                        .padding(.horizontal, 24)
                        
                        Spacer(minLength: 30)
                        
                        VStack(spacing: 14) {
                            Button {
                                showLogin = true
                            } label: {
                                Text("Login")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                                    .background(Color.blue.opacity(0.85))
                                    .clipShape(Capsule())
                            }
                            
                            Button {
                                showSignup = true
                            } label: {
                                Text("Sign Up")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.blue)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                                    .background(Color.white.opacity(0.1))
                                    .overlay(Capsule().stroke(Color.blue.opacity(0.8), lineWidth: 1.5))
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 20)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: $showLogin) {
                AuthView(initialMode: true)
            }
            .navigationDestination(isPresented: $showSignup) {
                AuthView(initialMode: false)
            }
        }
    }
}

private struct FeatureRow: View {
    let icon: String
    let color: Color
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 48, height: 48)
                .background(color.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }
}

#Preview {
    LandingPageView()
}
