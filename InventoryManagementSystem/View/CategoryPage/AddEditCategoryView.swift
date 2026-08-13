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
    
    private var availableCategories: [String] {
        var names = CategoryViewModel.presetCategories
        if let existingName = categoryToEdit?.name, !existingName.isEmpty, !names.contains(existingName) {
            names.append(existingName)
        }
        return names
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Category Details") {
                    Picker("Category Name", selection: $categoryModel.categoryName) {
                        ForEach(availableCategories, id: \.self) { name in
                            Text(name).tag(name)
                        }
                    }
                    .pickerStyle(.menu)
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
                    categoryModel.categoryName = CategoryViewModel.presetCategories.first ?? ""
                }
            }
            .alert("Category Name Error", isPresented: $categoryModel.showAlert){
                Button("Ok", role: .cancel){
                    categoryModel.showAlert = false
                }
            } message: {
                Text(categoryModel.alertMessage)
            }
        }
        .presentationDetents([.height(400)])
    }
}

#Preview {
    AddEditCategoryView()
}
