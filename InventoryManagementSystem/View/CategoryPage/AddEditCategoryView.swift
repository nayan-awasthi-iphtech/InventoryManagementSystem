//
//  AddEditCategoryView.swift
//  InventoryManagementSystem
//
//  Created by iPHTech 30 on 07/08/26.
//

import SwiftUI

struct AddEditCategoryView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var categoryModel: CategoryViewModel
    
    var categoryToEdit: Category?
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Category Details") {
                    TextField("Category Name", text: $categoryModel.categoryName)
                        .autocapitalization(.words)
                }
            }
            .navigationTitle(categoryToEdit == nil ? "New Category" : "Edit Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        categoryModel.clearFields()
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let success: Bool
                        if let category = categoryToEdit {
                            success = categoryModel.updateCategory(category)
                        } else {
                            success = categoryModel.addCategory()
                        }
                        
                        if success {
                            categoryModel.clearFields()
                            dismiss()
                        }
                    }
                }
            }
            .onAppear {
                if let category = categoryToEdit {
                    categoryModel.populateFields(for: category)
                } else {
                    categoryModel.clearFields()
                }
            }
        }
        .presentationDetents([.height(400)])
    }
}

#Preview {
    AddEditCategoryView()
}
