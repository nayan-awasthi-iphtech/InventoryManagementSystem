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
    
    private let viewContext = PersistenceController.shared.container.viewContext
    
    init(){
        fetchProducts()
    }
    
    func fetchProducts(){
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Product.name, ascending: true)]
        
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedSearch.isEmpty {
            fetchRequest.predicate = NSPredicate(
                format: "name CONTAINS[cd] %@ OR sku CONTAINS[cd] %@ OR barcode CONTAINS[cd] %@",
                trimmedSearch, trimmedSearch, trimmedSearch
            )
            
            do {
                products = try viewContext.fetch(fetchRequest)
            } catch {
                print("Error in fetching products: \(error.localizedDescription)")
                AlertMessage = "Unable to fetch products. Please try again."
            }
        }
    }
    
    func Addproducts()-> Bool{
        let trimmedName = productName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            AlertMessage = "Please enter a name for the product."
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
        
        if let category = selectedCategory {
            newProduct.product_category = category
        }
        
        if let supplier = selectedSupplier {
            newProduct.product_Supplier = supplier
        }
        
        return saveContext()
    }
    
    func updateProduct(_ product: Product) -> Bool{
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
            return true
        } catch{
            print("Error in saving product: \(error.localizedDescription)")
            return false
        }
    }
}
