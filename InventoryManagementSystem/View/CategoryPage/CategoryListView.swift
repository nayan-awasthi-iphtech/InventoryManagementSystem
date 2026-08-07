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
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    if categoryModel.categories.isEmpty {
                        ContentUnavailableView(
                            "No Categories Found",
                            systemImage: "folder.badge.plus",
                            description: Text("Tap '+' to create your first category.")
                        )
                    } else {
                        ForEach(categoryModel.categories, id: \.objectID) { category in
                            NavigationLink {
                                CategoryDetailView(category: category)
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "folder.fill")
                                        .font(.title3)
                                        .foregroundStyle(.blue)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(category.name ?? "N/A")
                                            .font(.body)
                                            .fontWeight(.medium)
                                        
                                        if let products = category.category_product {
                                            Text("\(products.count) Products")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        } else {
                                            Text("0 Products")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Button {
                                        categoryToEdit = category
                                        showAddSheet = true
                                    } label: {
                                        Image(systemName: "pencil")
                                            .foregroundStyle(.gray)
                                    }
                                    .buttonStyle(.borderless)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .onDelete(perform: categoryModel.deleteCategories)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Categories")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        categoryToEdit = nil
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                 AddEditCategoryView(categoryToEdit: categoryToEdit)
                    .environmentObject(categoryModel)
            }
        }
    }
}

#Preview {
    CategoryListView()
}
