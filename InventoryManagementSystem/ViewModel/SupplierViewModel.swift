//
//  SupplierViewModel.swift
//  InventoryManagementSystem
//
//  Created by iPHTech 30 on 10/08/26.
//

import SwiftUI
import CoreData
import Combine

class SupplierViewModel: ObservableObject {
    
    @Published var suppliers: [Supplier] = []
    @Published var categories: [Category] = []
    @Published var supplierName: String = ""
    @Published var supplierAddress: String = ""
    @Published var supplierContact: String = ""
    @Published var supplierGstNumber: String = ""
    @Published var supplierImageData: Data?
    @Published var supplierDetails: String = ""
    
    @Published var relatedAdmin: Admin?
    @Published var relatedCategory: Category?
    
    @Published var showAlert: Bool = false
    @Published var alertMsg: String = ""
    
    private let viewContext: NSManagedObjectContext
    private var contextObserver: AnyCancellable?
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext){
        self.viewContext = context
        fetchSuppliers()
        observeContextChanges()
    }
    
    private func observeContextChanges() {
        contextObserver = NotificationCenter.default
            .publisher(for: .NSManagedObjectContextDidSave, object: viewContext)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.fetchSuppliers()
            }
    }
    
    func fetchSuppliers(){
        let request: NSFetchRequest<Supplier> = Supplier.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Supplier.name, ascending: true)]
        
        do {
            suppliers = try viewContext.fetch(request)
        } catch {
            print("Error is coming in fetching suppliers")
            showAlert = true
            alertMsg = "Failed to fetch suppliers: \(error.localizedDescription)"
        }
    }
    
    func fetchCategories(){
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Category.name, ascending: true)]
        
        do {
            categories = try viewContext.fetch(request)
        } catch {
            print("Error in fetching categories: \(error.localizedDescription)")
        }
    }
    
    
    func addSupplier(admin: Admin? = nil, category: Category? = nil)-> Bool{
        let cleanedName = supplierName.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedAddress = supplierAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedContact = supplierContact.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedGST = supplierGstNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !cleanedName.isEmpty, !cleanedAddress.isEmpty, !cleanedContact.isEmpty, !cleanedGST.isEmpty else {
            showAlert = true
            alertMsg = "Please fill in all the fields."
            return false
        }
        
        guard cleanedName.count <= 30 else {
            alertMsg = "Category name must be 30 characters or less."
            showAlert = true
            return false
        }
        
        let newSupplier = Supplier(context: viewContext)
        newSupplier.id = UUID()
        newSupplier.name = cleanedName
        newSupplier.address = cleanedAddress
        newSupplier.contact = cleanedContact
        newSupplier.gstNumber = cleanedGST
        newSupplier.imageData = supplierImageData
        newSupplier.supplierDetail = supplierDetails
        
        if let ownerAdmin = admin ?? relatedAdmin ?? SessionManager.shared.currentAdmin {
            newSupplier.supplier_admin = ownerAdmin
        }
        
         return saveContext()
    }
    
    func updateSupplier(_ supplier: Supplier) -> Bool{
        let cleanedName = supplierName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedName.isEmpty else {
            alertMsg = "Please enter a name for the category"
            showAlert = true
            return false
        }
        
        if suppliers.contains(where: { $0.objectID != supplier.objectID && $0.name?.lowercased() == cleanedName.lowercased() }) {
            alertMsg = "This name is already registered. Please use a different name."
            showAlert = true
            return false
        }
        
        supplier.name = cleanedName
        supplier.address = supplierAddress
        supplier.contact = supplierContact
        supplier.gstNumber = supplierGstNumber
        supplier.imageData = supplierImageData
        supplier.supplierDetail = supplierDetails
        
        return saveContext()
    }
    
    func deleteSupplier(_ supplier: Supplier) -> Bool{
        viewContext.delete(supplier)
        return saveContext()
    }
    
    func deleteSuppliers(at offsets: IndexSet){
        for index in offsets {
            let category = suppliers[index]
            viewContext.delete(category)
        }
        _ = saveContext()
    }
    
    func populateFields(for supplier: Supplier){
        self.supplierName = supplier.name ?? ""
        self.supplierAddress = supplier.address ?? ""
        self.supplierContact = supplier.contact ?? ""
        self.supplierGstNumber = supplier.gstNumber ?? ""
        self.supplierDetails = supplier.supplierDetail ?? ""
        self.supplierImageData = supplier.imageData
    }
    
    func clearFields(){
        supplierName = ""
        supplierAddress = ""
        supplierContact = ""
        supplierGstNumber = ""
        supplierDetails = ""
        supplierImageData = nil
    }
    
    func saveContext() -> Bool{
        do {
            try viewContext.save()
            fetchSuppliers()
            print("Category saved successfully with the name \(supplierName)")
            return true
        } catch{
            print("Could not save context: \(error.localizedDescription)")
            return false
        }
    }
}
