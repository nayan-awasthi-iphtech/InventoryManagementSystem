//
//  OrderListView.swift
//  InventoryManagementSystem
//
//  Created by iPHTech 30 on 11/08/26.
//

import SwiftUI
import CoreData

struct OrderListView: View {
    
    @StateObject private var orderViewModel = OrderViewModel()
    @State private var selectedSection: OrdersSection = .orders
    @State private var showAddSheet: Bool = false
    @State private var orderToDelete: Order?
    @State private var showDeleteAlert: Bool = false
    
    enum OrdersSection: String, CaseIterable, Identifiable {
        case orders = "Orders"
        case reports = "Reports"
        
        var id: String { rawValue }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Inventora")
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundStyle(AppTheme.accent)
                            
                            Text("Orders")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundStyle(AppTheme.primaryText)
                        }
                        
                        Spacer()
                        
                        Button {
                            orderViewModel.clearFields()
                            showAddSheet = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 44, height: 44)
                                .background(AppTheme.accent)
                                .clipShape(Circle())
                                .shadow(color: AppTheme.accent.opacity(0.3), radius: 6, y: 3)
                        }
                        .padding(.top, 4)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    
                    Picker("Section", selection: $selectedSection) {
                        ForEach(OrdersSection.allCases) { section in
                            Text(section.rawValue).tag(section)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)
                    .padding(.top, 15)
                    
                    Group {
                        if selectedSection == .reports {
                          ReportsContent()
                        } else {
                            VStack(spacing: 0) {
                                Picker("Filter", selection: $orderViewModel.filterType) {
                                    Text("All").tag("all")
                                    Text("Purchase").tag("purchase")
                                    Text("Sale").tag("sale")
                                }
                                .pickerStyle(.segmented)
                                .padding(.horizontal, 16)
                                .padding(.top, 15)
                                .padding(.bottom, 10)
                                
                                if orderViewModel.filteredOrders.isEmpty {
                                    ContentUnavailableView(
                                        emptyTitle,
                                        systemImage: emptySystemImage,
                                        description: Text(emptyDescription)
                                    )
                                } else {
                                    List {
                                        ForEach(orderViewModel.filteredOrders, id: \.objectID) { order in
                                            NavigationLink(destination: OrderDetailView(order: order).environmentObject(orderViewModel)) {
                                                OrderRow(order: order)
                                                    .padding(10)
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 14)
                                                            .fill(AppTheme.cardBackground)
                                                    )
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 14)
                                                            .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                                                    )
                                            }
                                            .listRowBackground(Color.clear)
                                            .listRowInsets(EdgeInsets(top: 2, leading: 20, bottom: 4, trailing: 20))
                                            .listRowSeparator(.hidden)
                                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                                Button(role: .destructive) {
                                                    orderToDelete = order
                                                    showDeleteAlert = true
                                                } label: {
                                                    Label("Delete", systemImage: "trash")
                                                }
                                            }
                                        }
                                    }
                                    .contentMargins(.top, 6, for: .scrollContent)
                                    .scrollContentBackground(.hidden)
                                }
                            }
                        }
                    }
                }
                .sheet(isPresented: $showAddSheet) {
                    AddEditOrderView()
                        .environmentObject(orderViewModel)
                }
                .alert("Delete Order", isPresented: $showDeleteAlert) {
                    Button("Delete", role: .destructive) {
                        if let order = orderToDelete {
                            _ = orderViewModel.deleteOrder(order)
                        }
                        orderToDelete = nil
                    }
                    Button("Cancel", role: .cancel) {
                        orderToDelete = nil
                    }
                } message: {
                    Text("Are you sure you want to delete order '\(orderToDelete?.orderNumber ?? "this order")'? Stock levels will not be changed.")
                }
                .onAppear {
                    orderViewModel.fetchOrders()
                }
            }
        }
    }
    
    private var emptyTitle: String {
        switch orderViewModel.filterType {
        case "purchase":
            return orderViewModel.orders.isEmpty ? "No Orders" : "No Purchase Orders"
        case "sale":
            return orderViewModel.orders.isEmpty ? "No Orders" : "No Sale Orders"
        default:
            return "No Orders"
        }
    }
    
    private var emptySystemImage: String {
        orderViewModel.orders.isEmpty ? "doc.badge.plus" : "doc.text.magnifyingglass"
    }
    
    private var emptyDescription: String {
        if orderViewModel.orders.isEmpty {
            return "Tap + to create your first order."
        }
        switch orderViewModel.filterType {
        case "purchase":
            return "No purchase orders have been created yet."
        case "sale":
            return "No sale orders have been created yet."
        default:
            return "No orders have been created yet."
        }
    }
}

private struct OrderRow: View {
    @ObservedObject var order: Order
    
    var body: some View {
        HStack(spacing: 18) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(typeColor.opacity(0.15))
                
                Image(systemName: order.orderType == "purchase" ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                    .font(.title3)
                    .foregroundStyle(typeColor)
            }
            .frame(width: 44, height: 44)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(order.orderNumber ?? "Order")
                    .font(.headline)
                    .foregroundStyle(AppTheme.primaryText)
                    .lineLimit(1)
                
                Text("\(order.orderType?.capitalized ?? "Order") • \(order.orderDate?.formatted(date: .abbreviated, time: .omitted) ?? "N/A")")
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(order.totalAmount.formatted(.currency(code: "INR")))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.primaryText)
                
                Text(order.status ?? "Completed")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(statusColor)
            }
        }
        .padding(.vertical, 2)
    }
    
    private var typeColor: Color {
        order.orderType == "purchase" ? AppTheme.success : AppTheme.warning
    }
    
    private var statusColor: Color {
        switch order.status?.lowercased() {
        case "pending": return AppTheme.warning
        case "approved": return AppTheme.accent
        case "shipped": return .indigo
        case "delivered", "completed": return AppTheme.success
        case "cancelled": return AppTheme.danger
        default: return AppTheme.secondaryText
        }
    }
}

#Preview {
    OrderListView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
