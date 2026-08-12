//
//  DashboardScreenView.swift
//  InventoryManagementSystem
//
//  Created by iPHTech 30 on 05/08/26.
//

import SwiftUI
import CoreData

struct DashboardScreenView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var session = SessionManager.shared
    @StateObject private var dashboardViewModel = DashboardViewModel()
    @StateObject private var stockViewModel = StockViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 10) {
                        
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
                            
                            Button {
                                session.logout()
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
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            MetricCard(
                                iconName: "square.fill",
                                iconColor: .blue,
                                mainValue: "\(dashboardViewModel.totalProducts)",
                                label: "Total Products",
                                subtext: dashboardViewModel.totalProducts == 1 ? "1 product listed" : "\(dashboardViewModel.totalProducts) products listed",
                                subtextColor: .gray
                            )
                            
                            MetricCard(
                                iconName: "square.fill",
                                iconColor: .orange,
                                mainValue: "\(dashboardViewModel.totalStock)",
                                label: "Total Stock",
                                subtext: "Units in inventory",
                                subtextColor: .gray
                            )
                            
                            MetricCard(
                                iconName: "square.fill",
                                iconColor: .orange,
                                mainValue: "\(dashboardViewModel.lowStockCount)",
                                label: "Low Stock",
                                subtext: dashboardViewModel.lowStockCount == 0 ? "All good" : "Needs attention",
                                subtextColor: .orange
                            )
                            
                            MetricCard(
                                iconName: "square.fill",
                                iconColor: .red,
                                mainValue: "\(dashboardViewModel.outOfStockCount)",
                                label: "Out of Stock",
                                subtext: dashboardViewModel.outOfStockCount == 0 ? "Stock available" : "Urgent action",
                                subtextColor: .red
                            )
                            
                            MetricCard(
                                iconName: "square.fill",
                                iconColor: .indigo,
                                mainValue: "\(dashboardViewModel.ordersToday)",
                                label: "Orders Today",
                                subtext: dashboardViewModel.ordersToday == 1 ? "1 order placed" : "\(dashboardViewModel.ordersToday) orders placed",
                                subtextColor: .gray
                            )
                            
                            MetricCard(
                                iconName: "square.fill",
                                iconColor: .teal,
                                mainValue: INRCompactFormatter.string(from: dashboardViewModel.totalStockValue),
                                label: "Inventory Value",
                                subtext: "Value of total stock",
                                subtextColor: .gray
                            )
                            
                            MetricCard(
                                iconName: "square.fill",
                                iconColor: .green,
                                mainValue: "\(dashboardViewModel.suppliers.count)",
                                label: "Suppliers",
                                subtext: "Registered suppliers",
                                subtextColor: .gray
                            )
                            
                            MetricCard(
                                iconName: "square.fill",
                                iconColor: .purple,
                                mainValue: "\(dashboardViewModel.categories.count)",
                                label: "Categories",
                                subtext: "Product categories",
                                subtextColor: .gray
                            )
                        }
                        
                        RevenueCard(revenue: dashboardViewModel.monthlyRevenue, changePercent: dashboardViewModel.revenueChangePercent)
                        
                        RecentOrdersSection(orders: dashboardViewModel.orders)
                        
                        StockManagementSection()
                            .environmentObject(stockViewModel)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                dashboardViewModel.fetchAllData()
            }
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
        HStack(spacing: 12) {

            Image(systemName: iconName)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(iconColor)
                .frame(width: 34, height: 34)
                .background(
                    iconColor.opacity(0.12)
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 9)
                )

            VStack(alignment: .leading, spacing: 2) {

                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Text(mainValue)
                    .font(.system(size: 21, weight: .bold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(subtext)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(subtextColor)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .frame(height: 78)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(
                    Color(uiColor: .secondarySystemGroupedBackground)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    Color.primary.opacity(0.06),
                    lineWidth: 1
                )
        )
    }
}

struct RecentOrdersSection: View {
    let orders: [Order]
    
    private var recentOrders: [Order] {
        Array(orders.prefix(5))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("RECENT ORDERS")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.gray)
                .padding(.top, 8)
            
            if recentOrders.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 40))
                        .foregroundStyle(.gray.opacity(0.5))
                    Text("No Orders Yet")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                    Text("Create your first order from the Orders tab.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                VStack(spacing: 0) {
                    ForEach(recentOrders, id: \.objectID) { order in
                        NavigationLink(destination: OrderDetailView(order: order)) {
                            RecentOrderRow(order: order)
                        }
                        .buttonStyle(.plain)
                        
                        if order.objectID != recentOrders.last?.objectID {
                            Divider()
                                .padding(.leading, 56)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
    }
}

private struct RecentOrderRow: View {
    @ObservedObject var order: Order
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(typeColor.opacity(0.15))
                
                Image(systemName: order.orderType == "purchase" ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                    .font(.title3)
                    .foregroundStyle(typeColor)
            }
            .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(order.orderNumber ?? "Order")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                
                Text(order.orderDate?.formatted(date: .abbreviated, time: .omitted) ?? "N/A")
                    .font(.caption2)
                    .foregroundStyle(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 3) {
                Text(order.totalAmount.formatted(.currency(code: "INR")))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                Text(order.orderType?.capitalized ?? "Order")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(typeColor)
            }
        }
        .padding(.vertical, 10)
    }
    
    private var typeColor: Color {
        order.orderType == "purchase" ? .green : .orange
    }
}

struct RevenueCard: View {
    let revenue: [MonthlyRevenue]
    let changePercent: Double
    
    private var maxAmount: Double {
        revenue.map(\.amount).max() ?? 0
    }
    
    private var totalRevenue: Double {
        revenue.reduce(0) { $0 + $1.amount }
    }
    
    private func barHeight(for amount: Double) -> CGFloat {
        guard maxAmount > 0 else { return 4 }
        return 8 + (CGFloat(amount) / CGFloat(maxAmount)) * 60
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("MONTHLY REVENUE")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.gray)
            
            Text(totalRevenue.formatted(.currency(code: "INR")))
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.primary)
            
            HStack(alignment: .bottom, spacing: 12) {
                ForEach(Array(revenue.enumerated()), id: \.offset) { index, item in
                    VStack(spacing: 8) {
                        Spacer()
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(index == revenue.count - 1 ? Color.blue : Color.blue.opacity(0.25))
                            .frame(height: barHeight(for: item.amount))
                        
                        Text(item.month)
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
                
                Text(String(format: "%+.1f%%", changePercent))
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(changePercent >= 0 ? .green : .red)
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
