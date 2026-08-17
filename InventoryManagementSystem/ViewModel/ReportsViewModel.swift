import Foundation
import CoreData
import Combine

struct MonthlySalesData: Identifiable {
    let id = UUID()
    let month: String
    let sales: Double
    let purchases: Double
}

struct CategoryRevenue: Identifiable {
    let id = UUID()
    let name: String
    let amount: Double
}

struct BestSellingProduct: Identifiable {
    let id = UUID()
    let product: Product
    let quantitySold: Int32
    let revenue: Double
}

class ReportsViewModel: ObservableObject {
    
    let lowStockThreshold: Int32 = 5
    
    @Published var products: [Product] = []
    @Published var categories: [Category] = []

    @Published private(set) var totalSalesRevenue: Double = 0.0
    @Published private(set) var totalPurchaseValue: Double = 0.0
    @Published private(set) var monthlySales: [MonthlySalesData] = []
    @Published private(set) var bestSellingProducts: [BestSellingProduct] = []
    
    private let viewContext = PersistenceController.shared.container.viewContext
    private var contextObserver: AnyCancellable?
    
    init() {
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
    
    func fetchAllData() {
        fetchProducts()
        fetchCategories()
        calculateOrderMetrics()
    }
    
    private func fetchProducts() {
        let request: NSFetchRequest<Product> = Product.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Product.name, ascending: true)]
        
        do {
            products = try viewContext.fetch(request)
        } catch {
            print("Error fetching products: \(error.localizedDescription)")
        }
    }
    
    private func fetchCategories() {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Category.name, ascending: true)]
        
        do {
            categories = try viewContext.fetch(request)
        } catch {
            print("Error fetching categories: \(error.localizedDescription)")
        }
    }
    
    private func calculateOrderMetrics() {
        let salesPredicate = NSPredicate(format: "orderType == %@", "sale")
        let purchasePredicate = NSPredicate(format: "orderType == %@", "purchase")
        
        let saleOrders = fetchOrders(with: salesPredicate)
        let purchaseOrders = fetchOrders(with: purchasePredicate)
        
        self.totalSalesRevenue = saleOrders.reduce(0) { $0 + $1.totalAmount }
        self.totalPurchaseValue = purchaseOrders.reduce(0) { $0 + $1.totalAmount }
        
        self.bestSellingProducts = computeBestSellers(from: saleOrders)
  
        self.monthlySales = computeMonthlySales(sales: saleOrders, purchases: purchaseOrders)
    }
    
    private func fetchOrders(with predicate: NSPredicate) -> [Order] {
        let request: NSFetchRequest<Order> = Order.fetchRequest()
        request.predicate = predicate
        return (try? viewContext.fetch(request)) ?? []
    }
    
    private func computeBestSellers(from saleOrders: [Order]) -> [BestSellingProduct] {
        var aggregated: [NSManagedObjectID: (product: Product, quantity: Int32, revenue: Double)] = [:]
        
        for order in saleOrders {
            guard let items = order.order_orderItem as? Set<OrderItem> else { continue }
            for item in items {
                guard let product = item.orderItem_product else { continue }
                let existing = aggregated[product.objectID]
                aggregated[product.objectID] = (
                    product,
                    (existing?.quantity ?? 0) + item.quantity,
                    (existing?.revenue ?? 0) + (Double(item.quantity) * item.unitprice)
                )
            }
        }
        
        return aggregated.values
            .map { BestSellingProduct(product: $0.product, quantitySold: $0.quantity, revenue: $0.revenue) }
            .sorted { $0.quantitySold > $1.quantitySold }
    }
    
    private func computeMonthlySales(sales: [Order], purchases: [Order]) -> [MonthlySalesData] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        
        guard let firstOfThisMonth = calendar.date(bySetting: .day, value: 1, of: Date()) else { return [] }
        
        return (0..<12).reversed().compactMap { offset in
            guard let start = calendar.date(byAdding: .month, value: -offset, to: firstOfThisMonth),
                  let end = calendar.date(byAdding: .month, value: 1, to: start) else { return nil }
            
            let salesTotal = sales
                .compactMap { order -> (Date, Double)? in
                    guard let date = order.orderDate else { return nil }
                    return (date, order.totalAmount)
                }
                .filter { $0.0 >= start && $0.0 < end }
                .reduce(0) { $0 + $1.1 }
            
            let purchasesTotal = purchases
                .compactMap { order -> (Date, Double)? in
                    guard let date = order.orderDate else { return nil }
                    return (date, order.totalAmount)
                }
                .filter { $0.0 >= start && $0.0 < end }
                .reduce(0) { $0 + $1.1 }
            
            return MonthlySalesData(month: formatter.string(from: start), sales: salesTotal, purchases: purchasesTotal)
        }
    }
    
    var lowStockProducts: [Product] {
        products
            .filter { $0.quantity > 0 && $0.quantity < lowStockThreshold }
            .sorted { $0.quantity < $1.quantity }
    }
    
    var outOfStockProducts: [Product] {
        products.filter { $0.quantity == 0 }
    }
    
    var totalProducts: Int {
        products.count
    }
    
    var bestSalesMonth: MonthlySalesData? {
        monthlySales.max { $0.sales < $1.sales }
    }
    
    var bestSellingUnits: Int32 {
        bestSellingProducts.reduce(0) { $0 + $1.quantitySold }
    }
    
    var revenueByCategory: [CategoryRevenue] {
        categories.compactMap { category in
            let categoryProducts = (category.category_product as? Set<Product>) ?? []
            let amount = categoryProducts.reduce(0) { $0 + (Double($1.quantity) * $1.price) }
            guard amount > 0 else { return nil }
            return CategoryRevenue(name: category.name ?? "Uncategorized", amount: amount)
        }
        .sorted { $0.amount > $1.amount }
    }
    
    var inventoryValueByCategory: [CategoryRevenue] {
        categories.compactMap { category in
            let categoryProducts = (category.category_product as? Set<Product>) ?? []
            let amount = categoryProducts.reduce(0) { $0 + (Double($1.quantity) * $1.price) }
            guard !categoryProducts.isEmpty else { return nil }
            return CategoryRevenue(name: category.name ?? "Uncategorized", amount: amount)
        }
        .sorted { $0.amount > $1.amount }
    }
}
