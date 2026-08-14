//
//  DistributorListView.swift
//  InventoryManagementSystem
//
//  Created by iPHTech 30 on 13/08/26.
//

import SwiftUI
import CoreData

struct DistributorListView: View {
    
    @EnvironmentObject var distributorViewModel: DistributorViewModel
    
    @State private var distributorToDelete: Distributor?
    @State private var showDeleteAlert: Bool = false
    
    var body: some View {
        ZStack {
            
            AppTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                Group {
                    if distributorViewModel.distributors.isEmpty {
                        ContentUnavailableView(
                            "No Distributors available",
                            systemImage: "cube.box",
                            description: Text("Tap + to add the distributors")
                        )
                    } else {
                        List {
                            ForEach(distributorViewModel.distributors) { distributor in
                                NavigationLink(destination: DistributorDetailView(distributor: distributor).environmentObject(distributorViewModel)) {
                                    DistributorRow(distributor: distributor)
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
                                        distributorToDelete = distributor
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
                .alert("Delete Distributor", isPresented: $showDeleteAlert) {
                    Button("Delete", role: .destructive) {
                        if let distributor = distributorToDelete {
                            _ = distributorViewModel.deleteDistributor(distributor)
                        }
                        distributorToDelete = nil
                    }
                    Button("Cancel", role: .cancel) {
                        distributorToDelete = nil
                    }
                } message: {
                    Text("Are you sure you want to delete '\(distributorToDelete?.name ?? "this supplier")'? This action cannot be undone.")
                }
                .onAppear {
                    distributorViewModel.fetchDistributors()
                }
            }
        }
    }
}

private struct DistributorRow: View {
    @ObservedObject var distributor: Distributor
    
    var body: some View {
        HStack(spacing: 12) {
            Group {
                if let data = distributor.imageData, let image = UIImage(data: data) {
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
                Text(distributor.name ?? "Unnamed Supplier")
                    .font(.headline)
                    .foregroundStyle(AppTheme.primaryText)
                    .lineLimit(1)
                
                Text(distributor.address ?? "Unknown address")
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("Contact No.")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.secondaryText)
                
                Text(distributor.contact ?? "")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(AppTheme.primaryText)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    DistributorListView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
