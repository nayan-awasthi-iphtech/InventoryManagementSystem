//
//  ProductViewModel.swift
//  InventoryManagementSystem
//
//  Created by iPHTech 30 on 06/08/26.
//

import SwiftUI
import CoreData
import Combine

class ProductViewModel: ObservableObject {
    
    @Published var products: [Product] = []
    @Published var searchText: String = ""
    @Published var categories: [Category] = []
    @Published var suppliers: [Supplier] = []
    
    @Published var productName: String = ""
    @Published var productPrice: String = ""
    @Published var productBarcode: String = ""
    @Published var productQuantity: String = ""
    @Published var productDetail: String = ""
    @Published var productSKU: String = ""
    @Published var productImageData:Data? = nil
    
    @Published var selectedCategory: Category?
    @Published var selectedSupplier: Supplier?
    
    @Published var showAlert: Bool = false
    @Published var AlertMessage: String = ""
    
    private var viewContext: NSManagedObjectContext
    private var contextObserver: AnyCancellable?
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext){
        
        self.viewContext = context
        fetchProducts()
        fetchCategories()
        fetchSuppliers()
        observeContextChanges()
    }
    
    private func observeContextChanges() {
        contextObserver = NotificationCenter.default
            .publisher(for: .NSManagedObjectContextDidSave, object: viewContext)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.fetchProducts()
                self?.fetchCategories()
                self?.fetchSuppliers()
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
    
    func fetchSuppliers(){
        let request: NSFetchRequest<Supplier> = Supplier.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Supplier.name, ascending: true)]
        
        do {
            suppliers = try viewContext.fetch(request)
        } catch {
            print("Error in fetching suppliers: \(error.localizedDescription)")
        }
    }
    
    func fetchProducts(context: NSManagedObjectContext? = nil) {
        let targetContext = context ?? viewContext
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Product.name, ascending: true)]
        
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedSearch.isEmpty {
            fetchRequest.predicate = NSPredicate(
                format: "name CONTAINS[cd] %@ OR sku CONTAINS[cd] %@ OR barcode CONTAINS[cd] %@",
                trimmedSearch, trimmedSearch, trimmedSearch
            )
        }
        
        do {
            products = try targetContext.fetch(fetchRequest)
        } catch {
            print("Error in fetching products: \(error.localizedDescription)")
            AlertMessage = "Unable to fetch products. Please try again."
        }
    }
    
    func Addproducts()-> Bool{
        let trimmedName = productName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            AlertMessage = "Please enter a name for the product."
            showAlert = true
            return false
        }
        
        guard trimmedName.count <= 30 else {
            AlertMessage = "Category name must be 30 characters or less."
            showAlert = true
            return false
        }
        
        guard let category = selectedCategory else {
            AlertMessage = "Please select a Category for the product."
            showAlert = true
            return false
        }
        
        guard let supplier = selectedSupplier else {
            AlertMessage = "Please select a Supplier for the product."
            showAlert = true
            return false
        }
        
        let newProduct = Product(context: viewContext)
        newProduct.id = UUID()
        newProduct.name = trimmedName
        newProduct.barcode = productBarcode
        newProduct.detail = productDetail
        newProduct.price = Double(productPrice) ?? 0
        newProduct.imageData = productImageData
        newProduct.sku = productSKU
        newProduct.quantity = Int32(productQuantity) ?? 0
        
        if let currentAdmin = SessionManager.shared.currentAdmin {
            newProduct.product_admin = currentAdmin
        }
        
        newProduct.product_category = category
        newProduct.product_Supplier = supplier
        
        return saveContext()
    }
    
    func updateProduct(_ product: Product) -> Bool {
        let trimmedName = productName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            AlertMessage = "Please enter a name for the product."
            showAlert = true
            return false
        }
        
        product.name = trimmedName
        product.sku = productSKU.trimmingCharacters(in: .whitespacesAndNewlines)
        product.barcode = productBarcode.trimmingCharacters(in: .whitespacesAndNewlines)
        product.detail = productDetail.trimmingCharacters(in: .whitespacesAndNewlines)
        product.price = Double(productPrice) ?? 0.0
        product.quantity = Int32(productQuantity) ?? 0
        product.imageData = productImageData
        
        if let category = selectedCategory {
            product.product_category = category
        }
        
        if let supplier = selectedSupplier {
            product.product_Supplier = supplier
        }
        
        return saveContext()
    }
    
    func deleteProduct(_ product: Product){
        viewContext.delete(product)
        _ = saveContext()
    }
    
    func deleteProducts(at offsets: IndexSet) {
        for index in offsets {
            let product = products[index]
            viewContext.delete(product)
        }
        _ = saveContext()
    }
    
    func populateFields(from product: Product){
        productName = product.name ?? ""
        productSKU = product.sku ?? ""
        productBarcode = product.barcode ?? ""
        productDetail = product.detail ?? ""
        productPrice = product.price > 0 ? String(format: "%.2f", product.price) : ""
        productQuantity = "\(product.quantity)"
        productImageData = product.imageData
        selectedCategory = product.product_category
        selectedSupplier = product.product_Supplier
    }
    
    func clearFields(){
        productName = ""
        productSKU = ""
        productBarcode = ""
        productDetail = ""
        productPrice = ""
        productQuantity = ""
        productImageData = nil
        selectedCategory = nil
        selectedSupplier = nil
    }
    
    func saveContext()-> Bool{
        do {
            try viewContext.save()
            fetchProducts()
            print("Product saved successfully")
            return true
        } catch{
            viewContext.rollback()
            print("Error in saving product: \(error.localizedDescription)")
            return false
        }
    }
}
