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
                            description: Text("Tap + to add the suppliers")
                        )
                    } else {
                        List {
                            ForEach(distributorViewModel.distributors) { distributor in
                                NavigationLink(destination: DistributorDetailView(distributor: distributor).environmentObject(distributorViewModel)) {
                                    DistributorRow(distributor: distributor)
                                }
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
                Text(distributor.name ?? "Unnamed Supplier")
                    .font(.headline)
                    .lineLimit(1)
                
                Text(distributor.address ?? "Unknown address")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("Contact No.")
                    .font(.caption)
                    .fontWeight(.bold)
                
                Text(distributor.contact ?? "")
                    .font(.caption)
                    .fontWeight(.medium)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    DistributorListView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}