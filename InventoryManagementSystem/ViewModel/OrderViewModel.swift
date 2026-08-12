//
//  OrderViewModel.swift
//  InventoryManagementSystem
//
//  Created by iPHTech 30 on 11/08/26.
//

import SwiftUI
import CoreData
import Combine

struct OrderItemDraft: Identifiable {
    let id = UUID()
    let product: Product
    var quantity: Int32
    
    var lineTotal: Double {
        Double(quantity) * product.price
    }
}

class OrderViewModel: ObservableObject {
    
    static let orderStatuses = ["Pending", "Approved", "Shipped", "Delivered", "Cancelled"]
    
    @Published var orders: [Order] = []
    @Published var products: [Product] = []
    @Published var suppliers: [Supplier] = []
    
    @Published var orderType: String = "purchase"
    @Published var orderStatus: String = "Pending"
    @Published var filterType: String = "all"
    @Published var selectedSupplier: Supplier?
    @Published var selectedProduct: Product?
    @Published var selectedQuantity: Int = 1
    @Published var selectedItems: [OrderItemDraft] = []
    
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    private let viewContext: NSManagedObjectContext
    private var contextObserver: AnyCancellable?
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.viewContext = context
        fetchOrders()
        fetchProducts()
        fetchSuppliers()
        observeContextChanges()
    }
    
    private func observeContextChanges() {
        contextObserver = NotificationCenter.default
            .publisher(for: .NSManagedObjectContextDidSave, object: viewContext)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.fetchOrders()
                self?.fetchProducts()
                self?.fetchSuppliers()
            }
    }
    
    func fetchOrders() {
        let request: NSFetchRequest<Order> = Order.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Order.orderDate, ascending: false)]
        
        if let currentAdmin = SessionManager.shared.currentAdmin {
            request.predicate = NSPredicate(format: "order_admin == %@", currentAdmin)
        }
        
        do {
            orders = try viewContext.fetch(request)
        } catch {
            print("Error in fetching orders: \(error.localizedDescription)")
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
    
    func fetchSuppliers() {
        let request: NSFetchRequest<Supplier> = Supplier.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Supplier.name, ascending: true)]
        
        do {
            suppliers = try viewContext.fetch(request)
        } catch {
            print("Error in fetching suppliers: \(error.localizedDescription)")
        }
    }
    
    var isPurchase: Bool {
        orderType == "purchase"
    }
    
    var filteredOrders: [Order] {
        switch filterType {
        case "purchase":
            return orders.filter { $0.orderType == "purchase" }
        case "sale":
            return orders.filter { $0.orderType == "sale" }
        default:
            return orders
        }
    }
    
    var totalAmount: Double {
        selectedItems.reduce(0) { $0 + (Double($1.quantity) * $1.product.price) }
    }
    
    func addItem(product: Product?, quantity: Int32) {
        guard let product = product, quantity > 0 else {
            return
        }

        if let index = selectedItems.firstIndex(
            where: { $0.product.objectID == product.objectID }
        ) {
            selectedItems[index].quantity += quantity
        } else {
            let newItem = OrderItemDraft(
                product: product,
                quantity: quantity
            )
            selectedItems.append(newItem)
        }
    }
    
    func removeItem(product: Product?, quantity: Int32) {
        guard let product = product, quantity > 0 else { return }
        
        if let index = selectedItems.firstIndex(where: { $0.product.objectID == product.objectID }) {
            var items = selectedItems
            items[index].quantity -= quantity
            
            if items[index].quantity <= 0 {
                items.remove(at: index)
            }
            selectedItems = items
        }
    }
    
    func removeItem(at offsets: IndexSet) {
        selectedItems.remove(atOffsets: offsets)
    }
    
    func clearFields() {
        orderType = "purchase"
        orderStatus = "Pending"
        selectedSupplier = nil
        selectedProduct = nil
        selectedQuantity = 1
        selectedItems = []
    }
    
    func createOrder() -> Bool {
        if isPurchase && selectedSupplier == nil {
            alertMessage = "Please select a supplier for the purchase order."
            showAlert = true
            return false
        }
        
        guard !selectedItems.isEmpty else {
            alertMessage = "Please add at least one item to the order."
            showAlert = true
            return false
        }
        
        if !isPurchase {
            for item in selectedItems where item.product.quantity < item.quantity {
                alertMessage = "Insufficient stock for '\(item.product.name ?? "this product")'. Available: \(item.product.quantity)."
                showAlert = true
                return false
            }
        }
        
        let newOrder = Order(context: viewContext)
        newOrder.id = UUID()
        newOrder.orderNumber = generateOrderNumber()
        newOrder.orderType = orderType
        newOrder.status = orderStatus
        newOrder.orderDate = Date()
        newOrder.totalAmount = totalAmount
        newOrder.order_admin = SessionManager.shared.currentAdmin
        
        if isPurchase {
            newOrder.order_supplier = selectedSupplier
        }
        
        for item in selectedItems {
            let orderItem = OrderItem(context: viewContext)
            orderItem.id = UUID()
            orderItem.quantity = item.quantity
            orderItem.unitprice = item.product.price
            orderItem.orderItem_order = newOrder
            orderItem.orderItem_product = item.product
        }
        
        if orderStatus == "Delivered" {
            guard applyStockChanges(for: newOrder) else {
                alertMessage = "Cannot create order: insufficient stock for one or more items."
                showAlert = true
                return false
            }
        }
        
        return saveContext()
    }
    
    func deleteOrder(_ order: Order) -> Bool {
        if let items = order.order_orderItem as? Set<OrderItem> {
            for item in items {
                viewContext.delete(item)
            }
        }
        viewContext.delete(order)
        return saveContext()
    }
    
    func updateStatus(_ order: Order, to status: String) -> Bool {
        let current = (order.status ?? "").lowercased()
        let target = status.lowercased()
        
        guard target != current else { return true }
        
        if target == "delivered" {
            guard applyStockChanges(for: order) else {
                alertMessage = "Cannot mark this order as delivered: insufficient stock for one or more items."
                showAlert = true
                return false
            }
        }
        
        order.status = status
        return saveContext()
    }
    
    private func generateOrderNumber() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        return "ORD-\(formatter.string(from: Date()))"
    }
    
    private func applyStockChanges(for order: Order) -> Bool {
        guard let items = order.order_orderItem as? Set<OrderItem> else { return false }
        
        let isPurchase = order.orderType == "purchase"
        let transactionType = order.orderType ?? ""
        
        for item in items {
            guard let product = item.orderItem_product else { continue }
            let qty = item.quantity
            
            if !isPurchase && product.quantity < qty {
                return false
            }
            
            let delta = isPurchase ? qty : -qty
            let previousQuantity = product.quantity
            product.quantity = previousQuantity + delta
            createStockLog(for: product, previousQuantity: previousQuantity, newQuantity: product.quantity, changed: delta, transactionType: transactionType)
        }
        
        return true
    }
    
    private func createStockLog(for product: Product, previousQuantity: Int32, newQuantity: Int32, changed: Int32, transactionType: String) {
        let log = StockLog(context: viewContext)
        log.id = UUID()
        log.previousQuantity = previousQuantity
        log.newQuantity = newQuantity
        log.quantityChanged = changed
        log.transactionType = transactionType
        log.date = Date()
        log.stockLog_product = product
        log.stockLog_admin = SessionManager.shared.currentAdmin
    }
    
    func saveContext() -> Bool {
        do {
            try viewContext.save()
            fetchOrders()
            fetchProducts()
            print("Order saved successfully")
            return true
        } catch {
            viewContext.rollback()
            print("Error in saving order: \(error.localizedDescription)")
            return false
        }
    }
}
