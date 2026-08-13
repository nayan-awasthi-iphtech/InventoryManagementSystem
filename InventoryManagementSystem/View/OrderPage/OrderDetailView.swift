//
//  OrderDetailView.swift
//  InventoryManagementSystem
//
//  Created by iPHTech 30 on 11/08/26.
//

import SwiftUI
import CoreData

struct OrderDetailView: View {
    
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var order: Order
    @StateObject private var orderViewModel = OrderViewModel()
    
    @State private var showDeleteAlert = false
    
    private var isPurchase: Bool {
        order.orderType == "purchase"
    }
    
    private var items: [OrderItem] {
        (order.order_orderItem as? Set<OrderItem>)?
            .sorted { ($0.orderItem_product?.name ?? "") < ($1.orderItem_product?.name ?? "") } ?? []
    }
    
    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    header
                    
                    infoSection
                    
                    itemsSection
                    
                    totalSection
                }
                .padding()
            }
        }
        .navigationTitle("Order")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button(role: .destructive) {
                    showDeleteAlert = true
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(.red)
                }
            }
        }
        .alert("Delete Order", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                if orderViewModel.deleteOrder(order) {
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete order '\(order.orderNumber ?? "this order")'? Stock levels will not be changed.")
        }
    }
    
    private var header: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(typeColor.opacity(0.15))
                    .frame(width: 72, height: 72)
                
                Image(systemName: isPurchase ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(typeColor)
            }
            
            VStack(spacing: 6) {
                Text(order.orderNumber ?? "Order")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 8) {
                    Text(order.orderType?.capitalized ?? "Order")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(typeColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(typeColor.opacity(0.12))
                        .clipShape(Capsule())
                    
                    Text(order.status?.capitalized ?? "Completed")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(statusColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(statusColor.opacity(0.12))
                        .clipShape(Capsule())
                }
                
                Text(order.orderDate?.formatted(date: .long, time: .shortened) ?? "N/A")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "info.circle")
                    .font(.headline)
                    .foregroundStyle(.blue)
                Text("Order Information")
                    .font(.headline)
            }
            
            Divider()
            
            infoRow(
                icon: "building.2",
                label: isPurchase ? "Supplier" : "Distributor",
                value: isPurchase ? (order.order_supplier?.name ?? "N/A") : (order.order_distributor?.name ?? "N/A")
            )
            infoRow(
                icon: "tag.fill",
                label: "Order Type",
                value: order.orderType?.capitalized ?? "N/A"
            )
            
            HStack(spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(.secondary)
                        .frame(width: 20)
                    Text("Status")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                    
                    if isDelivered {
                        Image(systemName: "lock.fill")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                Picker("Status", selection: statusBinding) {
                    ForEach(OrderViewModel.orderStatuses, id: \.self) { status in
                        Text(status).tag(status)
                    }
                }
                .pickerStyle(.menu)
                .tint(statusColor)
                .disabled(isDelivered)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var itemsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "shippingbox.fill")
                    .font(.headline)
                    .foregroundStyle(.blue)
                Text("Order Items (\(items.count))")
                    .font(.headline)
            }
            
            Divider()
            
            if items.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "shippingbox")
                        .font(.system(size: 40))
                        .foregroundStyle(.gray.opacity(0.5))
                    Text("No Items")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            } else {
                VStack(spacing: 0) {
                    ForEach(items, id: \.objectID) { item in
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.orderItem_product?.name ?? "Unnamed Product")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.primary)
                                
                                Text("\(item.quantity) × \(item.unitprice.formatted(.currency(code: "INR")))")
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                            }
                            
                            Spacer()
                            
                            Text((Double(item.quantity) * item.unitprice).formatted(.currency(code: "INR")))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        .padding(.vertical, 8)
                        
                        if item.objectID != items.last?.objectID {
                            Divider()
                        }
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var totalSection: some View {
        HStack {
            Text("Total Amount")
                .font(.headline)
            Spacer()
            Text(order.totalAmount.formatted(.currency(code: "INR")))
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundStyle(.secondary)
                    .frame(width: 20)
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.trailing)
        }
    }
    
    private var isDelivered: Bool {
        (order.status ?? "").lowercased() == "delivered"
    }
    
    private var statusBinding: Binding<String> {
        Binding(
            get: { order.status ?? "Pending" },
            set: { newValue in
                guard !isDelivered else { return }
                if newValue != order.status {
                    _ = orderViewModel.updateStatus(order, to: newValue)
                }
            }
        )
    }
    
    private var typeColor: Color {
        isPurchase ? .green : .orange
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
    let context = PersistenceController.preview.container.viewContext
    
    let sampleOrder = Order(context: context)
    sampleOrder.orderNumber = "ORD-20260811120000"
    sampleOrder.orderType = "purchase"
    sampleOrder.status = "Completed"
    sampleOrder.orderDate = Date()
    sampleOrder.totalAmount = 2999.00
    
    return NavigationStack {
        OrderDetailView(order: sampleOrder)
    }
}
