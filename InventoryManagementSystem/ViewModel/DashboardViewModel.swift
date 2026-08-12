//
//  DashboardViewModel.swift
//  InventoryManagementSystem
//
//  Created by iPHTech 30 on 10/08/26.
//

import Foundation
import CoreData
import Combine

struct MonthlyRevenue: Identifiable {
    let id = UUID()
    let month: String
    let amount: Double
}

class DashboardViewModel: ObservableObject {
    
    @Published var products: [Product] = []
    @Published var suppliers: [Supplier] = []
    @Published var categories: [Category] = []
    @Published var orders: [Order] = []
    
    private let viewContext = PersistenceController.shared.container.viewContext
    private var contextObserver: AnyCancellable?
    
    init(){
        fetchAllData()
        observeContextChanges()
    }
    
    private func observeContextChanges() {
        contextObserver = NotificationCenter.default
            .publisher(for: .NSManagedObjectContextDidSave, object: viewContext)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.fetchAllData()
            }
    }
    
    func fetchAllData(){
        fetchProducts()
        fetchSuppliers()
        fetchCategories()
        fetchOrders()
    }
    
    func fetchProducts(){
        let request: NSFetchRequest<Product> = Product.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Product.name, ascending: true)]
        
        do {
            products = try viewContext.fetch(request)
        } catch {
            print("Error in fetching products: \(error.localizedDescription)")
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
    
    func fetchCategories(){
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Category.name, ascending: true)]
        
        do {
            categories = try viewContext.fetch(request)
        } catch {
            print("Error in fetching categories: \(error.localizedDescription)")
        }
    }
    
    func fetchOrders(){
        let request: NSFetchRequest<Order> = Order.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Order.orderDate, ascending: false)]
        
        do {
            orders = try viewContext.fetch(request)
        } catch {
            print("Error in fetching orders: \(error.localizedDescription)")
        }
    }
    
    var totalProducts: Int {
        products.count
    }
    
    var totalStock: Int {
        products.reduce(0) { $0 + Int($1.quantity) }
    }
    
    var lowStockCount: Int {
        products.filter { $0.quantity > 0 && $0.quantity < 5 }.count
    }
    
    var outOfStockCount: Int {
        products.filter { $0.quantity == 0 }.count
    }
    
    var totalStockValue: Double {
        products.reduce(0) { $0 + (Double($1.quantity) * $1.price) }
    }
    
    var ordersToday: Int {
        let calendar = Calendar.current
        return orders.filter { calendar.isDateInToday($0.orderDate ?? Date()) }.count
    }
    
    private var saleOrders: [Order] {
        orders.filter { $0.orderType == "sale" }
    }
    
    var monthlyRevenue: [MonthlyRevenue] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        
        guard let firstOfThisMonth = calendar.date(bySetting: .day, value: 1, of: Date()) else { return [] }
        
        let saleOrders = self.saleOrders
        return (0..<6).reversed().compactMap { offset in
            guard let start = calendar.date(byAdding: .month, value: -offset, to: firstOfThisMonth),
                  let end = calendar.date(byAdding: .month, value: 1, to: start) else { return nil }
            
            let amount = saleOrders
                .filter { order in
                    guard let orderDate = order.orderDate else { return false }
                    return orderDate >= start && orderDate < end
                }
                .reduce(0) { $0 + $1.totalAmount }
            
            return MonthlyRevenue(month: formatter.string(from: start), amount: amount)
        }
    }
    
    var totalRevenue: Double {
        monthlyRevenue.reduce(0) { $0 + $1.amount }
    }
    
    var revenueChangePercent: Double {
        guard monthlyRevenue.count >= 2 else { return 0 }
        let previous = monthlyRevenue[monthlyRevenue.count - 2].amount
        let current = monthlyRevenue[monthlyRevenue.count - 1].amount
        guard previous > 0 else { return current > 0 ? 100 : 0 }
        return ((current - previous) / previous) * 100
    }
}
