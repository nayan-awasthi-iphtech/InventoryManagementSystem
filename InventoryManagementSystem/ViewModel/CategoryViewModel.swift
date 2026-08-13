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
    
    static let presetCategories = ["Electronics", "Furniture", "Grocery", "Clothing", "Accessories"]
    
    @Published var categories: [Category] = []
    @Published var categoryName: String = ""
    
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    @Published var SelectedAdmin: Admin?
    @Published var SelectedProduct: Product?
    
    private let viewContext: NSManagedObjectContext
    private var contextObserver: AnyCancellable?
    
    init(context:NSManagedObjectContext = PersistenceController.shared.container.viewContext){
        self.viewContext = context
        fetchCategories()
        observeContextChanges()
    }
    
    private func observeContextChanges() {
        contextObserver = NotificationCenter.default
            .publisher(for: .NSManagedObjectContextDidSave, object: viewContext)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.fetchCategories()
            }
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
        
        guard cleanedName.count <= 30 else {
            alertMessage = "Category name must be 30 characters or less."
            showAlert = true
            return false
        }
        
        if categories.contains(where: { $0.name?.lowercased() == cleanedName.lowercased() }) {
            alertMessage = "This name is already registered. Please use a different name."
            showAlert = true
            return false
        }
        
        let newCategory = Category(context: viewContext)
        newCategory.id = UUID()
        newCategory.name = cleanedName
        
        if let ownerAdmin = admin ?? SelectedAdmin ?? SessionManager.shared.currentAdmin {
            newCategory.category_admin = ownerAdmin
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
        
        if categories.contains(where: { $0.objectID != category.objectID && $0.name?.lowercased() == cleanedName.lowercased() }) {
            alertMessage = "This name is already registered. Please use a different name."
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
            print("Category saved successfully with the name \(categoryName)")
            return true
        } catch{
            print("Could not save context: \(error.localizedDescription)")
            return false
        }
    }
}
