//
//  DistributorViewModel.swift
//  InventoryManagementSystem
//
//  Created by iPHTech 30 on 13/08/26.
//

import SwiftUI
import CoreData
import Combine

class DistributorViewModel: ObservableObject {
    
    @Published var distributors: [Distributor] = []
    @Published var categories: [Category] = []
    @Published var distributorName: String = ""
    @Published var distributorAddress: String = ""
    @Published var distributorContact: String = ""
    @Published var distributorGstNumber: String = ""
    @Published var distributorImageData: Data?
    
    @Published var relatedAdmin: Admin?
    @Published var relatedCategory: Category?
    
    @Published var showAlert: Bool = false
    @Published var alertMsg: String = ""
    
    private let viewContext: NSManagedObjectContext
    private var contextObserver: AnyCancellable?
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext){
        self.viewContext = context
        fetchDistributors()
    }
    
    func fetchDistributors(){
        let request: NSFetchRequest<Distributor> = Distributor.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Distributor.name, ascending: true)]
        
        do {
            distributors = try viewContext.fetch(request)
        } catch {
            print("Error is coming in fetching distributors")
            showAlert = true
            alertMsg = "Failed to fetch distributors: \(error.localizedDescription)"
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
    
    
    func addDistributor(admin: Admin? = nil, category: Category? = nil)-> Bool{
        let cleanedName = distributorName.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedAddress = distributorAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedContact = distributorContact.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedGST = distributorGstNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !cleanedName.isEmpty, !cleanedAddress.isEmpty, !cleanedContact.isEmpty, !cleanedGST.isEmpty else {
            showAlert = true
            alertMsg = "Please fill in all the fields."
            return false
        }
        
        guard cleanedName.count <= 30 else {
            alertMsg = "Distributor name must be 30 characters or less."
            showAlert = true
            return false
        }
        
        let newDistributor = Distributor(context: viewContext)
        newDistributor.id = UUID()
        newDistributor.name = cleanedName
        newDistributor.address = cleanedAddress
        newDistributor.contact = cleanedContact
        newDistributor.gstNumber = cleanedGST
        newDistributor.imageData = distributorImageData
        
        if let ownerAdmin = admin ?? relatedAdmin ?? SessionManager.shared.currentAdmin {
            newDistributor.distributor_admin = ownerAdmin
        }
        
         return saveContext()
    }
    
    func updateDistributor(_ distributor: Distributor) -> Bool{
        let cleanedName = distributorName.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedAddress = distributorAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedContact = distributorContact.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedGST = distributorGstNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !cleanedName.isEmpty else {
            alertMsg = "Please enter a name for the distributor"
            showAlert = true
            return false
        }
        
        if distributors.contains(where: { $0.objectID != distributor.objectID && $0.name?.lowercased() == cleanedName.lowercased() }) {
            alertMsg = "This name is already registered. Please use a different name."
            showAlert = true
            return false
        }
        
        distributor.name = cleanedName
        distributor.address = cleanedAddress
        distributor.contact = cleanedContact
        distributor.gstNumber = cleanedGST
        distributor.imageData = distributorImageData
        
        return saveContext()
    }
    
    func deleteDistributor(_ distributor: Distributor) -> Bool{
        viewContext.delete(distributor)
        return saveContext()
    }
    
    func deleteDistributors(at offsets: IndexSet){
        for index in offsets {
            let distributor = distributors[index]
            viewContext.delete(distributor)
        }
        _ = saveContext()
    }
    
    func populateFields(for distributor: Distributor){

        self.distributorName = distributor.name ?? ""
        self.distributorAddress = distributor.address ?? ""
        self.distributorContact = distributor.contact ?? ""
        self.distributorGstNumber = distributor.gstNumber ?? ""
        self.distributorImageData = distributor.imageData
    }
    
    func clearFields(){
        
        distributorName = ""
        distributorAddress = ""
        distributorContact = ""
        distributorGstNumber = ""
        distributorImageData = nil
    }
    
    func saveContext() -> Bool{
        do {
            try viewContext.save()
            fetchDistributors()
            print("Distributor saved successfully with the name \(distributorName)")
            return true
        } catch{
            print("Could not save context: \(error.localizedDescription)")
            return false
        }
    }
}
