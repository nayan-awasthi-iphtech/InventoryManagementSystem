//
//  StockViewModel.swift
//  InventoryManagementSystem
//
//  Created by iPHTech 30 on 12/08/26.
//

import SwiftUI
import CoreData
import Combine

class StockViewModel: ObservableObject {
    
    @Published var products: [Product] = []
    @Published var stockLogs: [StockLog] = []
    
    @Published var selectedProduct: Product?
    @Published var quantity: String = ""
    
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    private let viewContext: NSManagedObjectContext
    private var contextObserver: AnyCancellable?
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.viewContext = context
        fetchProducts()
        fetchStockLogs()
        observeContextChanges()
    }
    
    private func observeContextChanges() {
        contextObserver = NotificationCenter.default
            .publisher(for: .NSManagedObjectContextDidSave, object: viewContext)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.fetchProducts()
                self?.fetchStockLogs()
            }
    }
    
    func fetchProducts() {
        let request: NSFetchRequest<Product> = Product.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Product.name, ascending: true)]
        
        do {
            products = try viewContext.fetch(request)
        } catch {
            print("Error in fetching products: \(error.localizedDescription)")
        }
    }
    
    func fetchStockLogs() {
        let request: NSFetchRequest<StockLog> = StockLog.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \StockLog.date, ascending: false)]
        
        if let currentAdmin = SessionManager.shared.currentAdmin {
            request.predicate = NSPredicate(format: "stockLog_admin == %@", currentAdmin)
        }
        
        do {
            stockLogs = try viewContext.fetch(request)
        } catch {
            print("Error in fetching stock logs: \(error.localizedDescription)")
        }
    }
    
    func performStockIn() -> Bool {
        guard let product = selectedProduct else {
            alertMessage = "Please select a product."
            showAlert = true
            return false
        }
        
        let qty = Int32(quantity) ?? 0
        guard qty > 0 else {
            alertMessage = "Please enter a valid quantity greater than zero."
            showAlert = true
            return false
        }
        
        let previous = product.quantity
        product.quantity = previous + qty
        createLog(for: product, previous: previous, new: product.quantity, changed: qty, type: "stockin")
        return saveContext()
    }
    
    func performStockOut() -> Bool {
        guard let product = selectedProduct else {
            alertMessage = "Please select a product."
            showAlert = true
            return false
        }
        
        let qty = Int32(quantity) ?? 0
        guard qty > 0 else {
            alertMessage = "Please enter a valid quantity greater than zero."
            showAlert = true
            return false
        }
        
        guard product.quantity >= qty else {
            alertMessage = "Insufficient stock for '\(product.name ?? "this product")'. Available: \(product.quantity)."
            showAlert = true
            return false
        }
        
        let previous = product.quantity
        product.quantity = previous - qty
        createLog(for: product, previous: previous, new: product.quantity, changed: -qty, type: "stockout")
        return saveContext()
    }
    
    private func createLog(for product: Product, previous: Int32, new: Int32, changed: Int32, type: String) {
        let log = StockLog(context: viewContext)
        log.id = UUID()
        log.previousQuantity = previous
        log.newQuantity = new
        log.quantityChanged = changed
        log.transactionType = type
        log.date = Date()
        log.stockLog_product = product
        log.stockLog_admin = SessionManager.shared.currentAdmin
    }
    
    func saveContext() -> Bool {
        do {
            try viewContext.save()
            fetchProducts()
            fetchStockLogs()
            print("Stock updated successfully")
            return true
        } catch {
            viewContext.rollback()
            print("Error in saving stock: \(error.localizedDescription)")
            alertMessage = "Failed to update stock. Please try again."
            showAlert = true
            return false
        }
    }
}
