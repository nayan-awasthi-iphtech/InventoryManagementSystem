//
//  SplashScreenView.swift
//  InventoryManagementSystem
//
//  Created by iPHTech 30 on 05/08/26.
//

import SwiftUI

struct SplashScreenView: View {
    
    @StateObject private var session = SessionManager.shared
    @State private var isActive: Bool = false
    @State private var scaleAmount: CGFloat = 0.85
    @State private var opacityAmount: Double = 0.0
    
    var body: some View {
        ZStack {
            if isActive {
                if session.isLoggedIn {
                    RootTabView()
                } else {
                    AuthView()
                }
            } else {
                ZStack {
                    RadialGradient(
                        colors: [Color(white: 0.18), Color(white: 0.08)],
                        center: .center,
                        startRadius: 20,
                        endRadius: 400
                    )
                    .ignoresSafeArea()
                    
                    VStack(spacing: 24) {
                        ZStack {
                            Circle()
                                .fill(Color.red.opacity(0.35))
                                .frame(width: 220, height: 220)
                                .blur(radius: 30)
                            
                            Image("splashimg")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 200, height: 200)
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
                                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 8)
                        }
                        
                        VStack(spacing: 8) {
                            Text("Inventora")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .shadow(color: .white.opacity(0.15), radius: 6)
                            
                            Text("Precision in Every Count.")
                                .font(.title)
                                .fontWeight(.medium)
                                .fontDesign(.serif)
                                .italic()
                                .foregroundStyle(Color.gray.opacity(0.85))
                        }
                    }
                    .scaleEffect(scaleAmount)
                    .opacity(opacityAmount)
                    .onAppear {
                        withAnimation(.easeOut(duration: 0.8)) {
                            self.scaleAmount = 1.0
                            self.opacityAmount = 1.0
                        }
                    }
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            self.isActive = true
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
