//
//  CategoryViewModel.swift
//  InventoryManagementSystem
//
//  Created by iPHTech 30 on 07/08/26.
//

import SwiftUI
import Combine
import CoreData

class CategoryViewModel: ObservableObject {
    
    @Published var categories: [Category] = []
    @Published var categoryName: String = ""
    
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    @Published var SelectedAdmin: Admin?
    @Published var SelectedProduct: Product?
    
    private let viewContext: NSManagedObjectContext
    
    init(context:NSManagedObjectContext = PersistenceController.shared.container.viewContext){
        self.viewContext = context
        fetchCategories()
    }
    
    func fetchCategories(){
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Category.name, ascending: true)]
        
        do{
            categories = try viewContext.fetch(request)
        } catch{
            print("Error in fetching categories: \(error.localizedDescription)")
        }
    }
    
    func addCategory(admin: Admin? = nil) -> Bool{
        let cleanedName = categoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedName.isEmpty else {
            alertMessage = "Please enter a name for the category"
            showAlert = true
            return false
        }
        
        if categories.contains(where: { $0.name?.lowercased() == cleanedName.lowercased()}){
            showAlert = true
            alertMessage = "This name is already registered. Please use a different name for category"
            return false
        }
        
        let newCategory = Category(context: viewContext)
        newCategory.name = cleanedName
        
        if let admin = SelectedAdmin {
            newCategory.category_admin = admin
        }
        
        if let product = SelectedProduct {
            newCategory.addToCategory_product(product)
        }
        
        return saveContext()
    }
    
    func updateCategory(_ category: Category) -> Bool{
        let cleanedName = categoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedName.isEmpty else {
            alertMessage = "Please enter a name for the category"
            showAlert = true
            return false
        }
        
        category.name = cleanedName
        return saveContext()
    }
    
    func deleteCategory(_ category: Category) -> Bool{
        viewContext.delete(category)
        return saveContext()
    }
    
    func deleteCategories(at offsets: IndexSet){
        for index in offsets {
            let category = categories[index]
            viewContext.delete(category)
        }
        _ = saveContext()
    }
    
    func populateFields(for category: Category){
        self.categoryName = category.name ?? ""
    }
    
    func clearFields(){
        categoryName = ""
    }
    
    func saveContext() -> Bool{
        do {
            try viewContext.save()
            fetchCategories()
            print("Category saved successfully")
            return true
        } catch{
            print("Could not save context: \(error.localizedDescription)")
            return false
        }
    }
}
