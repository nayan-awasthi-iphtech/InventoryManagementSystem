//
//  ReportsView.swift
//  InventoryManagementSystem
//
//  Created by iPHTech 30 on 12/08/26.

import SwiftUI
import CoreData

struct ReportsContent: View {
    
    @StateObject private var reportsViewModel = ReportsViewModel()
    @State private var selectedTab: ReportTab = .lowStock
    
    enum ReportTab: String, CaseIterable, Identifiable {
        case bestSelling = "Best Selling"
        case lowStock = "Low Stock"
        case sales = "Sales"
        case charts = "Charts"
        
        var id: String { rawValue }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Picker("Report", selection: $selectedTab) {
                ForEach(ReportTab.allCases) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.top, 15)
            
            Group {
                switch selectedTab {
                case .bestSelling:
                    BestSellingReportView(viewModel: reportsViewModel)
                case .lowStock:
                    LowStockReportView(viewModel: reportsViewModel)
                case .sales:
                    MonthlySalesReportView(viewModel: reportsViewModel)
                case .charts:
                    ChartsReportView(viewModel: reportsViewModel)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            reportsViewModel.fetchAllData()
        }
    }
}

struct ReportsView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ZStack {
                        Text("Reports")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding(.top, 8)
                    
                    ReportsContent()
                }
            }
        }
    }
}

// MARK: - Low Stock

private struct LowStockReportView: View {
    @ObservedObject var viewModel: ReportsViewModel
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ReportStatCard(
                        icon: "exclamationmark.triangle.fill",
                        color: .orange,
                        value: "\(viewModel.lowStockProducts.count)",
                        label: "Low Stock Items"
                    )
                    ReportStatCard(
                        icon: "xmark.octagon.fill",
                        color: .red,
                        value: "\(viewModel.outOfStockProducts.count)",
                        label: "Out of Stock"
                    )
                }
                
                if viewModel.lowStockProducts.isEmpty && viewModel.outOfStockProducts.isEmpty {
                    ContentUnavailableView(
                        "All Stock Levels Healthy",
                        systemImage: "checkmark.seal.fill",
                        description: Text("No products are currently low on stock or out of stock.")
                    )
                } else {
                    if !viewModel.lowStockProducts.isEmpty {
                        stockSection(
                            title: "Low Stock (\(viewModel.lowStockProducts.count))",
                            icon: "exclamationmark.triangle.fill",
                            color: .orange,
                            products: viewModel.lowStockProducts
                        )
                    }
                    
                    if !viewModel.outOfStockProducts.isEmpty {
                        stockSection(
                            title: "Out of Stock (\(viewModel.outOfStockProducts.count))",
                            icon: "xmark.octagon.fill",
                            color: .red,
                            products: viewModel.outOfStockProducts
                        )
                    }
                }
            }
            .padding(16)
        }
    }
    
    private func stockSection(title: String, icon: String, color: Color, products: [Product]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.headline)
                    .foregroundStyle(color)
                Text(title)
                    .font(.headline)
            }
            
            Divider()
            
            VStack(spacing: 0) {
                ForEach(Array(products.enumerated()), id: \.element.objectID) { index, product in
                    LowStockRow(product: product, color: color)
                    
                    if index != products.count - 1 {
                        Divider()
                            .padding(.leading, 56)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private struct LowStockRow: View {
    @ObservedObject var product: Product
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Group {
                if let data = product.imageData, let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(color.opacity(0.15))
                        .overlay(
                            Image(systemName: "cube.fill")
                                .foregroundStyle(color)
                        )
                }
            }
            .frame(width: 40, height: 40)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 3) {
                Text(product.name ?? "Unnamed Product")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                
                Text(product.product_category?.name ?? "No Category")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            
            Spacer()
            
            Text("\(product.quantity)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(color)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Best Selling

private struct BestSellingReportView: View {
    @ObservedObject var viewModel: ReportsViewModel
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ReportStatCard(
                        icon: "trophy.fill",
                        color: .orange,
                        value: "\(viewModel.bestSellingProducts.count)",
                        label: "Products Sold"
                    )
                    ReportStatCard(
                        icon: "cart.fill",
                        color: .green,
                        value: "\(viewModel.bestSellingUnits)",
                        label: "Total Units Sold"
                    )
                }
                
                if viewModel.bestSellingProducts.isEmpty {
                    ContentUnavailableView(
                        "No Sales Yet",
                        systemImage: "cart",
                        description: Text("Products will appear here once sale orders are created.")
                    )
                } else {
                    bestSellingList
                }
            }
            .padding(16)
        }
    }
    
    private var bestSellingList: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "trophy.fill")
                    .font(.headline)
                    .foregroundStyle(.orange)
                Text("Best Selling Products")
                    .font(.headline)
            }
            
            Divider()
            
            VStack(spacing: 0) {
                let maxQuantity = viewModel.bestSellingProducts.first?.quantitySold ?? 1
                ForEach(Array(viewModel.bestSellingProducts.enumerated()), id: \.element.id) { index, item in
                    BestSellingRow(
                        rank: index + 1,
                        product: item.product,
                        quantitySold: item.quantitySold,
                        revenue: item.revenue,
                        maxQuantity: maxQuantity
                    )
                    
                    if index != viewModel.bestSellingProducts.count - 1 {
                        Divider()
                            .padding(.leading, 56)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private struct BestSellingRow: View {
    let rank: Int
    @ObservedObject var product: Product
    let quantitySold: Int32
    let revenue: Double
    let maxQuantity: Int32
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(rankColor.opacity(0.15))
                    Text("\(rank)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(rankColor)
                }
                .frame(width: 32, height: 32)
                
                Group {
                    if let data = product.imageData, let image = UIImage(data: data) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    } else {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.orange.opacity(0.15))
                            .overlay(
                                Image(systemName: "cube.fill")
                                    .foregroundStyle(Color.orange)
                            )
                    }
                }
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(product.name ?? "Unnamed Product")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    
                    Text(product.product_category?.name ?? "No Category")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 3) {
                    Text("\(quantitySold) sold")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(.orange)
                    
                    Text(revenue.formatted(.currency(code: "INR")))
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.systemGray5))
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.orange, .yellow],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(8, geo.size.width * CGFloat(maxQuantity > 0 ? Double(quantitySold) / Double(maxQuantity) : 0)))
                }
            }
            .frame(height: 8)
        }
        .padding(.vertical, 10)
    }
    
    private var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .secondary
        }
    }
}

// MARK: - Monthly Sales

private struct MonthlySalesReportView: View {
    @ObservedObject var viewModel: ReportsViewModel
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ReportStatCard(
                        icon: "arrow.up.circle.fill",
                        color: .green,
                        value: viewModel.totalSalesRevenue.formatted(.currency(code: "INR")),
                        label: "Total Sales"
                    )
                    ReportStatCard(
                        icon: "arrow.down.circle.fill",
                        color: .blue,
                        value: viewModel.totalPurchaseValue.formatted(.currency(code: "INR")),
                        label: "Total Purchases"
                    )
                }
                
                monthlyChart
                
                if let best = viewModel.bestSalesMonth, best.sales > 0 {
                    HStack(spacing: 12) {
                        Image(systemName: "trophy.fill")
                            .font(.title3)
                            .foregroundStyle(.orange)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Best Month")
                                .font(.caption)
                                .foregroundStyle(.gray)
                            Text("\(best.month) • \(best.sales.formatted(.currency(code: "INR")))")
                                .font(.subheadline)
                                .fontWeight(.bold)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
            .padding(16)
        }
    }
    
    private var monthlyChart: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("MONTHLY SALES (12 MONTHS)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.gray)
            
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(viewModel.monthlySales) { item in
                    VStack(spacing: 8) {
                        Spacer()
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(item.sales > 0 ? Color.green.opacity(item.sales == viewModel.monthlySales.map(\.sales).max() ? 1.0 : 0.35) : Color.green.opacity(0.1))
                            .frame(height: barHeight(for: item.sales, max: maxSales))
                        
                        Text(item.month)
                            .font(.system(size: 8))
                            .foregroundStyle(.gray)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 140)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var maxSales: Double {
        viewModel.monthlySales.map(\.sales).max() ?? 0
    }
    
    private func barHeight(for amount: Double, max: Double) -> CGFloat {
        guard max > 0 else { return 4 }
        return 8 + (CGFloat(amount) / CGFloat(max)) * 100
    }
}

// MARK: - Charts

private struct ChartsReportView: View {
    @ObservedObject var viewModel: ReportsViewModel
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                salesVsPurchaseChart
                revenueByCategoryChart
            }
            .padding(16)
        }
    }
    
    private var salesVsPurchaseChart: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "chart.bar.xaxis")
                    .foregroundStyle(.blue)
                Text("SALES VS PURCHASES")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.gray)
            }
            
            HStack(alignment: .bottom, spacing: 10) {
                ForEach(viewModel.monthlySales) { item in
                    VStack(spacing: 4) {
                        Spacer()
                        
                        HStack(alignment: .bottom, spacing: 3) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.green)
                                .frame(height: barHeight(for: item.sales, max: maxAmount))
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.blue)
                                .frame(height: barHeight(for: item.purchases, max: maxAmount))
                        }
                        .frame(width: 12)
                        
                        Text(item.month)
                            .font(.system(size: 8))
                            .foregroundStyle(.gray)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 150)
            
            HStack(spacing: 16) {
                legend(color: .green, label: "Sales")
                legend(color: .blue, label: "Purchases")
                Spacer()
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var revenueByCategoryChart: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "chart.pie.fill")
                    .foregroundStyle(.blue)
                Text("INVENTORY VALUE BY CATEGORY")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.gray)
            }
            
            let items = viewModel.inventoryValueByCategory
            let maxValue = items.map(\.amount).max() ?? 0
            
            if items.isEmpty {
                Text("No data available yet.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else {
                VStack(spacing: 12) {
                    ForEach(items) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(item.name)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                Spacer()
                                Text(INRCompactFormatter.string(from: item.amount))
                                    .font(.caption)
                                    .fontWeight(.bold)
                            }
                            
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color(.systemGray5))
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [.blue, .indigo],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: max(8, geo.size.width * CGFloat(maxValue > 0 ? item.amount / maxValue : 0)))
                                }
                            }
                            .frame(height: 8)
                        }
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var maxAmount: Double {
        max(viewModel.monthlySales.map(\.sales).max() ?? 0,
            viewModel.monthlySales.map(\.purchases).max() ?? 0)
    }
    
    private func barHeight(for amount: Double, max: Double) -> CGFloat {
        guard max > 0 else { return 4 }
        return 6 + (CGFloat(amount) / CGFloat(max)) * 110
    }
    
    private func legend(color: Color, label: String) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.caption)
                .foregroundStyle(.gray)
        }
    }
}

// MARK: - Shared

private struct ReportStatCard: View {
    let icon: String
    let color: Color
    let value: String
    let label: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(color)
                .padding(6)
                .background(color.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 4))
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    ReportsView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
