//
//  DashboardScreenView.swift
//  InventoryManagementSystem
//
//  Created by iPHTech 30 on 05/08/26.
//

import SwiftUI
import CoreData

struct DashboardScreenView: View {
    
    var onShowSuppliers: () -> Void = {}
    var onShowDistributors: () -> Void = {}
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var session = SessionManager.shared
    @StateObject private var dashboardViewModel = DashboardViewModel()
    @StateObject private var stockViewModel = StockViewModel()
    @State private var showProfileSheet = false
    
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
                                    .foregroundStyle(AppTheme.accent)
                                
                                Text("Dashboard")
                                    .font(.system(size: 34, weight: .bold))
                                    .foregroundStyle(AppTheme.primaryText)
                            }
                            
                            Spacer()
                            
                            Button {
                                showProfileSheet = true
                            } label: {
                                if let imageData = session.currentAdmin?.imageData,
                                   let image = UIImage(data: imageData) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 45, height: 45)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(AppTheme.accent.opacity(0.3), lineWidth: 1.5)
                                        )
                                } else {
                                    Image(systemName: "person.crop.circle.fill")
                                        .font(.system(size: 40))
                                        .foregroundStyle(AppTheme.secondaryText)
                                }
                            }
                            .padding(.top, 6)
                            .padding(.horizontal, 6)
                        }
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            MetricCard(
                                iconName: "square.fill",
                                iconColor: AppTheme.accent,
                                mainValue: "\(dashboardViewModel.totalProducts)",
                                label: "Total Products",
                                subtext: dashboardViewModel.totalProducts == 1 ? "1 product listed" : "\(dashboardViewModel.totalProducts) products listed",
                                subtextColor: AppTheme.secondaryText
                            )
                            
                            MetricCard(
                                iconName: "square.fill",
                                iconColor: AppTheme.warning,
                                mainValue: INRCompactFormatter.string(from: dashboardViewModel.totalStock),
                                label: "Total Stock",
                                subtext: "Units in inventory",
                                subtextColor: AppTheme.secondaryText
                            )
                            
                            MetricCard(
                                iconName: "square.fill",
                                iconColor: .indigo,
                                mainValue: "\(dashboardViewModel.ordersToday)",
                                label: "Orders Today",
                                subtext: dashboardViewModel.ordersToday == 1 ? "1 order placed" : "\(dashboardViewModel.ordersToday) orders placed",
                                subtextColor: AppTheme.secondaryText
                            )
                            
                            MetricCard(
                                iconName: "square.fill",
                                iconColor: .teal,
                                mainValue: INRCompactFormatter.string(from: dashboardViewModel.totalStockValue),
                                label: "Inventory Value",
                                subtext: "Value of total stock",
                                subtextColor: AppTheme.secondaryText
                            )
                            
                            Button {
                                onShowSuppliers()
                            } label: {
                                MetricCard(
                                    iconName: "square.fill",
                                    iconColor: .green,
                                    mainValue: "\(dashboardViewModel.suppliers.count)",
                                    label: "Suppliers",
                                    subtext: "Registered suppliers",
                                    subtextColor: AppTheme.secondaryText
                                )
                            }
                            .buttonStyle(.plain)
                            
                            Button {
                                onShowDistributors()
                            } label: {
                                MetricCard(
                                    iconName: "square.fill",
                                    iconColor: .purple,
                                    mainValue: "\(dashboardViewModel.distributors.count)",
                                    label: "Distributors",
                                    subtext: "Registered distributors",
                                    subtextColor: AppTheme.secondaryText
                                )
                            }
                            .buttonStyle(.plain)
                            
                            MetricCard(
                                iconName: "square.fill",
                                iconColor: .purple,
                                mainValue: "\(dashboardViewModel.categories.count)",
                                label: "Categories",
                                subtext: "Product categories",
                                subtextColor: AppTheme.secondaryText
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
            .sheet(isPresented: $showProfileSheet) {
                AdminProfileView()
            }
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
                    .foregroundStyle(AppTheme.secondaryText)
                    .lineLimit(1)

                Text(mainValue)
                    .font(.system(size: 21, weight: .bold))
                    .foregroundStyle(AppTheme.primaryText)
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
                    AppTheme.cardBackground
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
                .foregroundStyle(AppTheme.secondaryText)
                .padding(.top, 8)
            
            if recentOrders.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 40))
                        .foregroundStyle(AppTheme.secondaryText.opacity(0.5))
                    Text("No Orders Yet")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(AppTheme.secondaryText)
                    Text("Create your first order from the Orders tab.")
                        .font(.caption)
                        .foregroundStyle(AppTheme.secondaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(AppTheme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 14))
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
                .background(AppTheme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 14))
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
                    .foregroundStyle(AppTheme.primaryText)
                    .lineLimit(1)
                
                Text(order.orderDate?.formatted(date: .abbreviated, time: .omitted) ?? "N/A")
                    .font(.caption2)
                    .foregroundStyle(AppTheme.secondaryText)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 3) {
                Text(order.totalAmount.formatted(.currency(code: "INR")))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.primaryText)
                
                Text(order.orderType?.capitalized ?? "Order")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(typeColor)
            }
        }
        .padding(.vertical, 10)
    }
    
    private var typeColor: Color {
        order.orderType == "purchase" ? AppTheme.success : AppTheme.warning
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
                .foregroundStyle(AppTheme.secondaryText)
            
            Text(INRCompactFormatter.string(from: totalRevenue))
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(AppTheme.primaryText)
            
            HStack(alignment: .bottom, spacing: 12) {
                ForEach(Array(revenue.enumerated()), id: \.offset) { index, item in
                    VStack(spacing: 8) {
                        Spacer()
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(index == revenue.count - 1 ? AppTheme.accent : AppTheme.accent.opacity(0.25))
                            .frame(height: barHeight(for: item.amount))
                        
                        Text(item.month)
                            .font(.caption2)
                            .foregroundStyle(AppTheme.secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 80)
            
            Divider()
            
            HStack {
                Text("vs last month")
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)
                
                Spacer()
                
                Text(String(format: "%+.1f%%", changePercent))
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(changePercent >= 0 ? AppTheme.success : AppTheme.danger)
            }
        }
        .padding(16)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    DashboardScreenView()
}
