//
//  StockManagementView.swift
//  InventoryManagementSystem
//
//  Created by iPHTech 30 on 12/08/26.
//

import SwiftUI
import CoreData

struct StockManagementSection: View {
    
    @EnvironmentObject private var stockViewModel: StockViewModel
    @State private var selectedTab: StockTab = .stockIn
    
    enum StockTab: String, CaseIterable, Identifiable {
        case stockIn = "Stock In"
        case stockOut = "Stock Out"
        case history = "History"
        
        var id: String { rawValue }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("STOCK MANAGEMENT")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(AppTheme.secondaryText)
                .padding(.top, 8)
            
            VStack(spacing: 14) {
                Picker("Stock Action", selection: $selectedTab) {
                    ForEach(StockTab.allCases) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                
                switch selectedTab {
                case .stockIn:
                    StockMovementForm(
                        tint: AppTheme.success,
                        isStockIn: true,
                        stockViewModel: stockViewModel
                    )
                case .stockOut:
                    StockMovementForm(
                        tint: AppTheme.danger,
                        isStockIn: false,
                        stockViewModel: stockViewModel
                    )
                case .history:
                    StockHistoryView(stockViewModel: stockViewModel)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(AppTheme.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.primary.opacity(0.06), lineWidth: 1)
            )
        }
    }
}

private struct StockMovementForm: View {
    let tint: Color
    let isStockIn: Bool
    @ObservedObject var stockViewModel: StockViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Text("Product")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if let product = stockViewModel.selectedProduct {
                    Text("In stock: \(product.quantity)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(product.quantity > 0 ? AppTheme.success : AppTheme.danger)
                }
            }
            
            Picker("Product", selection: $stockViewModel.selectedProduct) {
                Text("Select a product").tag(nil as Product?)
                ForEach(stockViewModel.products, id: \.objectID) { product in
                    Text(product.name ?? "Unnamed Product")
                        .tag(product as Product?)
                }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 10) {
                Image(systemName: isStockIn ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                    .foregroundStyle(tint)
                
                TextField(isStockIn ? "Enter quantity to add" : "Enter quantity to remove", text: $stockViewModel.quantity)
                    .keyboardType(.numberPad)
            }
            .padding(.horizontal, 12)
            .frame(height: 44)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(uiColor: .systemGray).opacity(0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.primary.opacity(0.06), lineWidth: 1)
            )
            
            Button {
                let _ = isStockIn ? stockViewModel.performStockIn() : stockViewModel.performStockOut()
            } label: {
                Label(isStockIn ? "Add Stock" : "Remove Stock", systemImage: isStockIn ? "plus.circle.fill" : "minus.circle.fill")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(tint)
                    .clipShape(Capsule())
            }
        }
        .alert("Error", isPresented: $stockViewModel.showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(stockViewModel.alertMessage)
        }
    }
}

private struct StockHistoryView: View {
    @ObservedObject var stockViewModel: StockViewModel
    
    private var recentLogs: [StockLog] {
        Array(stockViewModel.stockLogs.prefix(10))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if recentLogs.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 32))
                        .foregroundStyle(AppTheme.secondaryText.opacity(0.5))
                    Text("No Stock History")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(AppTheme.secondaryText)
                    Text("Stock movements will appear here.")
                        .font(.caption)
                        .foregroundStyle(AppTheme.secondaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                ForEach(recentLogs, id: \.objectID) { log in
                    StockLogRow(log: log)
                    
                    if log.objectID != recentLogs.last?.objectID {
                        Divider()
                            .padding(.leading, 52)
                    }
                }
            }
        }
        .onAppear {
            stockViewModel.fetchStockLogs()
        }
    }
}

private struct StockLogRow: View {
    @ObservedObject var log: StockLog
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(tint.opacity(0.15))
                
                Image(systemName: iconName)
                    .font(.subheadline)
                    .foregroundStyle(tint)
            }
            .frame(width: 36, height: 36)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(log.stockLog_product?.name ?? "Unnamed Product")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                Text("\(log.previousQuantity) → \(log.newQuantity)")
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 3) {
                Text(changeText)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(tint)
                
                Text(log.date?.formatted(date: .abbreviated, time: .shortened) ?? "N/A")
                    .font(.caption2)
                    .foregroundStyle(AppTheme.secondaryText)
            }
        }
        .padding(.vertical, 6)
    }
    
    private var type: String {
        log.transactionType?.lowercased() ?? ""
    }
    
    private var tint: Color {
        switch type {
        case "stockin", "purchase": return AppTheme.success
        case "stockout": return AppTheme.danger
        case "sale": return AppTheme.warning
        default: return AppTheme.secondaryText
        }
    }
    
    private var iconName: String {
        switch type {
        case "stockin", "purchase": return "arrow.down.circle.fill"
        case "stockout": return "arrow.up.circle.fill"
        case "sale": return "arrow.up.right.circle.fill"
        default: return "arrow.left.arrow.right.circle.fill"
        }
    }
    
    private var changeText: String {
        let value = log.quantityChanged
        return value > 0 ? "+\(value)" : "\(value)"
    }
}

#Preview {
    ScrollView {
        StockManagementSection()
            .padding()
    }
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
