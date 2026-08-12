////
////  ReportsViewModel.swift
////  InventoryManagementSystem
////
////  Created by iPHTech 30 on 12/08/26.
////
//
//import Foundation
//import CoreData
//import Combine
//
//struct MonthlySalesData: Identifiable {
//    let id = UUID()
//    let month: String
//    let sales: Double
//    let purchases: Double
//}
//
//struct CategoryRevenue: Identifiable {
//    let id = UUID()
//    let name: String
//    let amount: Double
//}
//
//class ReportsViewModel: ObservableObject {
//    
//    let lowStockThreshold: Int = 5
//    
//    @Published var products: [Product] = []
//    @Published var orders: [Order] = []
//    @Published var categories: [Category] = []
//    
//    private let viewContext = PersistenceController.shared.container.viewContext
//    private var contextObserver: AnyCancellable?
//    
//    init() {
//        fetchAllData()
//        observeContextChanges()
//    }
//    
//    private func observeContextChanges() {
//        contextObserver = NotificationCenter.default
//            .publisher(for: .NSManagedObjectContextDidSave, object: viewContext)
//            .receive(on: RunLoop.main)
//            .sink { [weak self] _ in
//                self?.fetchAllData()
//            }
//    }
//    
//    func fetchAllData() {
//        fetchProducts()
//        fetchOrders()
//        fetchCategories()
//    }
//    
//    func fetchProducts() {
//        let request: NSFetchRequest<Product> = Product.fetchRequest()
//        request.sortDescriptors = [NSSortDescriptor(keyPath: \Product.name, ascending: true)]
//        
//        do {
//            products = try viewContext.fetch(request)
//        } catch {
//            print("Error in fetching products: \(error.localizedDescription)")
//        }
//    }
//    
//    func fetchOrders() {
//        let request: NSFetchRequest<Order> = Order.fetchRequest()
//        request.sortDescriptors = [NSSortDescriptor(keyPath: \Order.orderDate, ascending: false)]
//        
//        do {
//            orders = try viewContext.fetch(request)
//        } catch {
//            print("Error in fetching orders: \(error.localizedDescription)")
//        }
//    }
//    
//    func fetchCategories() {
//        let request: NSFetchRequest<Category> = Category.fetchRequest()
//        request.sortDescriptors = [NSSortDescriptor(keyPath: \Category.name, ascending: true)]
//        
//        do {
//            categories = try viewContext.fetch(request)
//        } catch {
//            print("Error in fetching categories: \(error.localizedDescription)")
//        }
//    }
//    
//    var lowStockProducts: [Product] {
//        products
//            .filter { $0.quantity > 0 && $0.quantity < Int32(lowStockThreshold) }
//            .sorted { $0.quantity < $1.quantity }
//    }
//    
//    var outOfStockProducts: [Product] {
//        products.filter { $0.quantity == 0 }
//    }
//    
//    var totalProducts: Int {
//        products.count
//    }
//    
//    private var saleOrders: [Order] {
//        orders.filter { $0.orderType == "sale" }
//    }
//    
//    private var purchaseOrders: [Order] {
//        orders.filter { $0.orderType == "purchase" }
//    }
//    
//    var totalSalesRevenue: Double {
//        saleOrders.reduce(0) { $0 + $1.totalAmount }
//    }
//    
//    var totalPurchaseValue: Double {
//        purchaseOrders.reduce(0) { $0 + $1.totalAmount }
//    }
//    
//    var monthlySales: [MonthlySalesData] {
//        let calendar = Calendar.current
//        let formatter = DateFormatter()
//        formatter.dateFormat = "MMM"
//        
//        guard let firstOfThisMonth = calendar.date(bySetting: .day, value: 1, of: Date()) else { return [] }
//        
//        return (0..<12).reversed().compactMap { offset in
//            guard let start = calendar.date(byAdding: .month, value: -offset, to: firstOfThisMonth),
//                  let end = calendar.date(byAdding: .month, value: 1, to: start) else { return nil }
//            
//            let sales = saleOrders
//                .filter { order in
//                    guard let orderDate = order.orderDate else { return false }
//                    return orderDate >= start && orderDate < end
//                }
//                .reduce(0) { $0 + $1.totalAmount }
//            
//            let purchases = purchaseOrders
//                .filter { order in
//                    guard let orderDate = order.orderDate else { return false }
//                    return orderDate >= start && orderDate < end
//                }
//                .reduce(0) { $0 + $1.totalAmount }
//            
//            return MonthlySalesData(month: formatter.string(from: start), sales: sales, purchases: purchases)
//        }
//    }
//    
//    var bestSalesMonth: MonthlySalesData? {
//        monthlySales.max { $0.sales < $1.sales }
//    }
//    
//    var revenueByCategory: [CategoryRevenue] {
//        categories.compactMap { category in
//            let products = (category.category_product as? Set<Product>) ?? []
//            let amount = products.reduce(0) { $0 + (Double($1.quantity) * $1.price) }
//            guard amount > 0 else { return nil }
//            return CategoryRevenue(name: category.name ?? "Uncategorized", amount: amount)
//        }
//        .sorted { $0.amount > $1.amount }
//    }
//    
//    var inventoryValueByCategory: [CategoryRevenue] {
//        categories.compactMap { category in
//            let products = (category.category_product as? Set<Product>) ?? []
//            let amount = products.reduce(0) { $0 + (Double($1.quantity) * $1.price) }
//            guard !products.isEmpty else { return nil }
//            return CategoryRevenue(name: category.name ?? "Uncategorized", amount: amount)
//        }
//        .sorted { $0.amount > $1.amount }
//    }
//}
