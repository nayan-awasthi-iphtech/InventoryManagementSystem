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
                } else {
                    Section("Distributor") {
                        Picker("Distributor", selection: $orderViewModel.selectedDistributor) {
                            Text("Select a distributor").tag(nil as Distributor?)
                            ForEach(orderViewModel.distributors, id: \.objectID) { distributor in
                                Text(distributor.name ?? "Unnamed Distributor")
                                    .tag(distributor as Distributor?)
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
                    Picker("Product", selection: $orderViewModel.selectedProduct) {
                        Text("Select a product").tag(nil as Product?)
                        ForEach(orderViewModel.products, id: \.objectID) { product in
                            Text(product.name ?? "Unnamed Product")
                                .tag(product as Product?)
                        }
                    }
                    
                    Stepper(value: $orderViewModel.selectedQuantity, in: 1...999) {
                        HStack {
                            Text("Quantity")
                            Spacer()
                            Text("\(orderViewModel.selectedQuantity)")
                                .fontWeight(.semibold)
                        }
                    }
                    
                    HStack(spacing: 12) {

                        Button {
                            orderViewModel.removeItem(
                                product: orderViewModel.selectedProduct,
                                quantity: Int32(orderViewModel.selectedQuantity)
                            )
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "minus.circle.fill")
                                    .font(.system(size: 16, weight: .semibold))

                                Text("Remove")
                                    .font(.system(size: 13, weight: .semibold))
                            }
                            .foregroundStyle(AppTheme.danger)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(AppTheme.danger.opacity(0.10))
                            )
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .disabled(orderViewModel.selectedProduct == nil)
                        .opacity(orderViewModel.selectedProduct == nil ? 0.5 : 1)


                        Button {
                            orderViewModel.addItem(
                                product: orderViewModel.selectedProduct,
                                quantity: Int32(orderViewModel.selectedQuantity)
                            )
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 16, weight: .semibold))

                                Text("Add")
                                    .font(.system(size: 13, weight: .semibold))
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(AppTheme.accent)
                            )
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .disabled(orderViewModel.selectedProduct == nil)
                        .opacity(orderViewModel.selectedProduct == nil ? 0.5 : 1)
                    }
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
                                        .foregroundStyle(AppTheme.secondaryText)
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
