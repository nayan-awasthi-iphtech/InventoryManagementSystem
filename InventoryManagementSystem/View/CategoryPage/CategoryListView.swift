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
    @State private var newCategorySelection: String? = nil
    
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
                            
                            Text("Categories")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundStyle(AppTheme.primaryText)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    
                    HStack(spacing: 10) {
                        Image(systemName: "folder.badge.plus")
                            .foregroundStyle(AppTheme.accent)
                        
                        Text("Add Category")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(AppTheme.primaryText)
                        
                        Spacer()
                        
                        Picker("Add Category", selection: $newCategorySelection) {
                            Text("Select").tag(nil as String?)
                            ForEach(CategoryViewModel.presetCategories, id: \.self) { name in
                                Text(name).tag(name as String?)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(AppTheme.accent)
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(AppTheme.cardBackground)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 12)
                    .onChange(of: newCategorySelection) { _, newValue in
                        guard let name = newValue else { return }
                        categoryModel.categoryName = name
                        _ = categoryModel.addCategory()
                        newCategorySelection = nil
                    }
                    .alert("Category Name Error", isPresented: $categoryModel.showAlert) {
                        Button("OK", role: .cancel) {
                            categoryModel.showAlert = false
                        }
                    } message: {
                        Text(categoryModel.alertMessage)
                    }
                    
                    Group {
                        if categoryModel.categories.isEmpty {
                            ContentUnavailableView(
                                "No Categories Found",
                                systemImage: "folder.badge.plus",
                                description: Text("Select a category above to add your first category.")
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
                                        .padding(16)
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
                                    .listRowInsets(EdgeInsets(top: 3, leading: 16, bottom: 4, trailing: 16))
                                    .listRowSeparator(.hidden)
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
                            .contentMargins(.top, 5, for: .scrollContent)
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
                .foregroundStyle(AppTheme.accent)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(category.name ?? "N/A")
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(AppTheme.primaryText)
                
                Text("\(category.category_product?.count ?? 0) Products")
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)
            }
            Spacer()
            
            Button {
                onEdit()
            } label: {
                Image(systemName: "pencil")
                    .foregroundStyle(AppTheme.secondaryText)
            }
            .buttonStyle(.borderless)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    CategoryListView()
}
