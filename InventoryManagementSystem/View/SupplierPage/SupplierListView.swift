//
//  SupplierListView.swift
//  InventoryManagementSystem
//
//  Created by iPHTech 30 on 10/08/26.
//

import SwiftUI
import CoreData

struct SupplierListView: View {
    
    @StateObject var supplierViewModel = SupplierViewModel()
    @State private var showAddSheet: Bool = false
    @State private var supplierToDelete: Supplier?
    @State private var showDeleteAlert: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                AppTheme.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    ZStack {
                        Text("Suppliers")
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
                    
                    Group {
                        if supplierViewModel.suppliers.isEmpty {
                            ContentUnavailableView(
                                "No Suppliers available",
                                systemImage: "cube.box",
                                description: Text("Tap + to add the suppliers")
                            )
                        } else {
                            List {
                                ForEach(supplierViewModel.suppliers) { supplier in
                                    NavigationLink(destination: SupplierDetailView(supplier: supplier).environmentObject(supplierViewModel)) {
                                        SupplierRow(supplier: supplier)
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button(role: .destructive) {
                                            supplierToDelete = supplier
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
                    AddEditSupplier()
                        .environmentObject(supplierViewModel)
                }
                .alert("Delete Supplier", isPresented: $showDeleteAlert) {
                    Button("Delete", role: .destructive) {
                        if let supplier = supplierToDelete {
                            _ = supplierViewModel.deleteSupplier(supplier)
                        }
                        supplierToDelete = nil
                    }
                    Button("Cancel", role: .cancel) {
                        supplierToDelete = nil
                    }
                } message: {
                    Text("Are you sure you want to delete '\(supplierToDelete?.name ?? "this supplier")'? This action cannot be undone.")
                }
                .onAppear {
                    supplierViewModel.fetchSuppliers()
                }
            }
        }
    }
}

private struct SupplierRow: View {
    @ObservedObject var supplier: Supplier
    
    var body: some View {
        HStack(spacing: 12) {
            Group {
                if let data = supplier.imageData, let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue.opacity(0.15))
                        .overlay(
                            Image(systemName: "person.2.fill")
                                .foregroundStyle(.blue)
                        )
                        .frame(width: 48, height: 48)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .frame(width: 48, height: 48)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(supplier.name ?? "Unnamed Supplier")
                    .font(.headline)
                    .lineLimit(1)
                
                Text(supplier.address ?? "Unknown address")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(supplier.contact ?? "")
                    .font(.caption)
                    .fontWeight(.medium)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    SupplierListView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
