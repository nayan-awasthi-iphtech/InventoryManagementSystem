//
//  DashboardScreenView.swift
//  InventoryManagementSystem
//
//  Created by iPHTech 30 on 05/08/26.
//

import SwiftUI

struct DashboardScreenView: View {

    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 10) {
                        
                        // Header with Title & Logout Button
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Inventora")
                                    .font(.title3)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.blue)
                                
                                Text("Dashboard")
                                    .font(.system(size: 34, weight: .bold))
                                    .foregroundStyle(.primary)
                            }
                            
                            Spacer()
                            
                            // MARK: - Logout Button
                            Button {
                                // Dismisses back to AuthView / Login Screen
                                dismiss()
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                        .font(.subheadline)
                                    Text("Logout")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                }
                                .foregroundStyle(.red)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.red.opacity(0.1))
                                .clipShape(Capsule())
                            }
                            .padding(.top, 4)
                        }
                        
                        // Metric Cards Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            MetricCard(
                                iconName: "square.fill",
                                iconColor: .blue,
                                mainValue: "1,284",
                                label: "Total Products",
                                subtext: "+12 this week",
                                subtextColor: .gray
                            )
                            
                            MetricCard(
                                iconName: "square.fill",
                                iconColor: .orange,
                                mainValue: "34",
                                label: "Low Stock",
                                subtext: "Needs attention",
                                subtextColor: .orange
                            )
                            
                            MetricCard(
                                iconName: "square.fill",
                                iconColor: .red,
                                mainValue: "8",
                                label: "Out of Stock",
                                subtext: "Urgent action",
                                subtextColor: .red
                            )
                            
                            MetricCard(
                                iconName: "square.fill",
                                iconColor: .blue,
                                mainValue: "57",
                                label: "Orders Today",
                                subtext: "+6 from yesterday",
                                subtextColor: .gray
                            )
                        }
                        
                        RevenueCard()
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("RECENT ORDERS")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.gray)
                                .padding(.top, 8)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct MetricCard: View {
    let iconName: String
    let iconColor: Color
    let mainValue: String
    let label: String
    let subtext: String
    let subtextColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: iconName)
                .font(.system(size: 10))
                .foregroundStyle(iconColor)
                .padding(6)
                .background(iconColor.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 4))
            
            Text(mainValue)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.primary)
            
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.gray)
            
            Text(subtext)
                .font(.caption2)
                .foregroundStyle(subtextColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct RevenueCard: View {
    let months = ["Apr", "May", "Jun", "Jul", "Aug"]
    let heights: [CGFloat] = [25, 35, 30, 45, 60]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("MONTHLY REVENUE")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.gray)
            
            Text("₹84,320")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.primary)
            
            HStack(alignment: .bottom, spacing: 12) {
                ForEach(0..<5) { index in
                    VStack(spacing: 8) {
                        Spacer()
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(index == 4 ? Color.blue : Color.blue.opacity(0.2))
                            .frame(height: heights[index])
                        
                        Text(months[index])
                            .font(.caption2)
                            .foregroundStyle(.gray)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 80)
            
            Divider()
            
            HStack {
                Text("vs last month")
                    .font(.caption)
                    .foregroundStyle(.gray)
                
                Spacer()
                
                Text("+18.4%")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.green)
            }
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    DashboardScreenView()
}
