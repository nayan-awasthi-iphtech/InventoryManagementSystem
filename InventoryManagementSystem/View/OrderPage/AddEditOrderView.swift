//
//  AddEditOrderView.swift
//  InventoryManagementSystem
//
//  Created by iPHTech 30 on 11/08/26.
//

import SwiftUI
import CoreData

struct AddEditOrderView: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var orderViewModel: OrderViewModel
    
    @State private var selectedProduct: Product?
    @State private var selectedQuantity: Int = 1
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Order Type") {
                    Picker("Type", selection: $orderViewModel.orderType) {
                        Text("Purchase").tag("purchase")
                        Text("Sale").tag("sale")
                    }
                    .pickerStyle(.segmented)
                }
                
                if orderViewModel.isPurchase {
                    Section("Supplier") {
                        Picker("Supplier", selection: $orderViewModel.selectedSupplier) {
                            Text("Select a supplier").tag(nil as Supplier?)
                            ForEach(orderViewModel.suppliers, id: \.objectID) { supplier in
                                Text(supplier.name ?? "Unnamed Supplier")
                                    .tag(supplier as Supplier?)
                            }
                        }
                    }
                }
                
                Section("Order Status") {
                    Picker("Status", selection: $orderViewModel.orderStatus) {
                        ForEach(OrderViewModel.orderStatuses, id: \.self) { status in
                            Text(status).tag(status)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Add Items") {
                    Picker("Product", selection: $selectedProduct) {
                        Text("Select a product").tag(nil as Product?)
                        ForEach(orderViewModel.products, id: \.objectID) { product in
                            Text(product.name ?? "Unnamed Product")
                                .tag(product as Product?)
                        }
                    }
                    
                    Stepper(value: $selectedQuantity, in: 1...999) {
                        HStack {
                            Text("Quantity")
                            Spacer()
                            Text("\(selectedQuantity)")
                                .fontWeight(.semibold)
                        }
                    }
                    
                    Button {
                        orderViewModel.addItem(product: selectedProduct, quantity: Int32(selectedQuantity))
                    } label: {
                        Label("Add Item", systemImage: "plus.circle.fill")
                    }
                    .disabled(selectedProduct == nil)
                }
                
                if !orderViewModel.selectedItems.isEmpty {
                    Section("Items (\(orderViewModel.selectedItems.count))") {
                        ForEach(orderViewModel.selectedItems) { item in
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.product.name ?? "Unnamed Product")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    Text("\(item.quantity) × \(item.product.price, specifier: "%.2f")")
                                        .font(.caption)
                                        .foregroundStyle(.gray)
                                }
                                
                                Spacer()
                                
                                Text(item.lineTotal.formatted(.currency(code: "INR")))
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                            .padding(.vertical, 2)
                        }
                        .onDelete { indices in
                            orderViewModel.removeItem(at: indices)
                        }
                    }
                }
                
                Section {
                    HStack {
                        Text("Total Amount")
                            .font(.headline)
                        Spacer()
                        Text(orderViewModel.totalAmount.formatted(.currency(code: "INR")))
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                }
            }
            .navigationTitle("New Order")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        orderViewModel.clearFields()
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if orderViewModel.createOrder() {
                            orderViewModel.clearFields()
                            dismiss()
                        }
                    }
                    .disabled(orderViewModel.selectedItems.isEmpty)
                }
            }
            .onAppear {
                orderViewModel.fetchProducts()
                orderViewModel.fetchSuppliers()
                orderViewModel.clearFields()
            }
            .alert("Error", isPresented: $orderViewModel.showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(orderViewModel.alertMessage)
            }
        }
    }
}

#Preview {
    AddEditOrderView()
        .environmentObject(OrderViewModel())
}
