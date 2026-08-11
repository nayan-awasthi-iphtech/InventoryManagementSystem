//
//  OrderListView.swift
//  InventoryManagementSystem
//
//  Created by iPHTech 30 on 11/08/26.
//

import SwiftUI
import CoreData

struct OrderListView: View {
    
    @StateObject var orderViewModel = OrderViewModel()
    @State private var showAddSheet: Bool = false
    @State private var orderToDelete: Order?
    @State private var showDeleteAlert: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ZStack {
                        Text("Orders")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        HStack {
                            Spacer()
                            Button {
                                showAddSheet = true
                            } label: {
                                Image(systemName: "plus")
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(.white)
                                    .frame(width: 40, height: 40)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.top, 8)
                    
                    Picker("Filter", selection: $orderViewModel.filterType) {
                        Text("All").tag("all")
                        Text("Purchase").tag("purchase")
                        Text("Sale").tag("sale")
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)
                    .padding(.top, 15)
                    
                    Group {
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
                                    }
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
                            .scrollContentBackground(.hidden)
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
        HStack(spacing: 12) {
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
                    .lineLimit(1)
                
                Text("\(order.orderType?.capitalized ?? "Order") • \(order.orderDate?.formatted(date: .abbreviated, time: .omitted) ?? "N/A")")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(order.totalAmount.formatted(.currency(code: "INR")))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(order.status ?? "Completed")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(statusColor)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var typeColor: Color {
        order.orderType == "purchase" ? .green : .orange
    }
    
    private var statusColor: Color {
        switch order.status?.lowercased() {
        case "pending": return .orange
        case "approved": return .blue
        case "shipped": return .indigo
        case "delivered", "completed": return .green
        case "cancelled": return .red
        default: return .gray
        }
    }
}

#Preview {
    OrderListView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
