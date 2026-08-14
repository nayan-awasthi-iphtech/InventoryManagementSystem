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
    @StateObject var distributorViewModel = DistributorViewModel()
    @Binding var orderCategory: Ordercategories
    @State private var showAddSheet: Bool = false
    @State private var supplierToDelete: Supplier?
    @State private var showDeleteAlert: Bool = false
    
    enum Ordercategories: String, Identifiable, CaseIterable{
        case supplier = "Suppliers"
        case distributer = "Distributors"
        
        var id: String {rawValue}
    }
    
    init(section: Binding<Ordercategories> = .constant(.supplier)) {
        _orderCategory = section
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
                            
                            Text(orderCategory == .supplier ? "Suppliers" : "Distributors")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundStyle(AppTheme.primaryText)
                        }
                        
                        Spacer()
                        
                        Button {
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
                    
                    Picker("Section", selection: $orderCategory){
                        ForEach(Ordercategories.allCases){ section in
                            Text(section.rawValue).tag(section)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 10)
                    
                    Group {
                        
                        if orderCategory == .distributer {
                            DistributorListView()
                                .environmentObject(distributorViewModel)
                        } else {
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
                                                .padding(12)
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
                                        .listRowInsets(EdgeInsets(top: 2, leading: 16, bottom: 4, trailing: 16))
                                        .listRowSeparator(.hidden)
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
                                .contentMargins(.top, 6, for: .scrollContent)
                                .scrollContentBackground(.hidden)
                            }
                        }
                    }
                    .sheet(isPresented: $showAddSheet) {
                        if orderCategory == .supplier {
                            AddEditSupplier()
                                .environmentObject(supplierViewModel)
                        } else {
                            AddEditDistributor()
                                .environmentObject(distributorViewModel)
                        }
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
                        .fill(AppTheme.accent.opacity(0.15))
                        .overlay(
                            Image(systemName: "person.2.fill")
                                .foregroundStyle(AppTheme.accent)
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
                    .foregroundStyle(AppTheme.primaryText)
                    .lineLimit(1)
                
                Text(supplier.address ?? "Unknown address")
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                
                Text("Contact No.")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.secondaryText)
                
                Text(supplier.contact ?? "")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(AppTheme.primaryText)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    SupplierListView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
