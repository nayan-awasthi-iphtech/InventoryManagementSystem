//
//  CategoryListView.swift
//  InventoryManagementSystem
//
//  Created by iPHTech 30 on 07/08/26.
//

import SwiftUI
import CoreData

struct CategoryListView: View {
    
    @StateObject var categoryModel = CategoryViewModel()
    @State private var showAddSheet: Bool = false
    @State private var categoryToEdit: Category? = nil
    @State private var categoryToDelete: Category? = nil
    @State private var showDeleteAlert: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ZStack {
                        Text("Categories")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        HStack {
                            Spacer()
                            Button {
                                categoryToEdit = nil
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
                        if categoryModel.categories.isEmpty {
                            ContentUnavailableView(
                                "No Categories Found",
                                systemImage: "folder.badge.plus",
                                description: Text("Tap '+' to create your first category.")
                            )
                        } else {
                            List {
                                ForEach(categoryModel.categories, id: \.objectID) { category in
                                    NavigationLink {
                                        CategoryDetailView(category: category)
                                    } label: {
                                        CategoryRow(category: category) {
                                            categoryToEdit = category
                                            showAddSheet = true
                                        }
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button(role: .destructive) {
                                            categoryToDelete = category
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
                    AddEditCategoryView(categoryToEdit: categoryToEdit)
                        .environmentObject(categoryModel)
                }
                .alert("Delete Category", isPresented: $showDeleteAlert) {
                    Button("Delete", role: .destructive) {
                        if let category = categoryToDelete {
                            _ = categoryModel.deleteCategory(category)
                        }
                        categoryToDelete = nil
                    }
                    Button("Cancel", role: .cancel) {
                        categoryToDelete = nil
                    }
                } message: {
                    Text("Are you sure you want to delete '\(categoryToDelete?.name ?? "this category")'? This action cannot be undone.")
                }
            }
        }
    }
}

private struct CategoryRow: View {
    @ObservedObject var category: Category
    let onEdit: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "folder.fill")
                .font(.title3)
                .foregroundStyle(.blue)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(category.name ?? "N/A")
                    .font(.body)
                    .fontWeight(.medium)
                
                Text("\(category.category_product?.count ?? 0) Products")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            
            Button {
                onEdit()
            } label: {
                Image(systemName: "pencil")
                    .foregroundStyle(.gray)
            }
            .buttonStyle(.borderless)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    CategoryListView()
}
