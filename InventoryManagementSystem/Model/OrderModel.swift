//
//  OrderModel.swift
//  InventoryManagementSystem
//
//  Created by iPHTech 30 on 17/08/26.
//

import Foundation
import CoreData

struct OrderModel {
    let id: UUID
    var orderNumber: String
    var orderType: String
    var status: String
    var totalAmount: Double
    var orderDate: Date
    var items: [OrderItemModel]
}

struct OrderItemModel {
    let id: UUID
    var quantity: Int32
    var unitPrice: Double
    var productID: UUID?
}

extension OrderModel {
    init(order: Order) {
        self.id = order.id ?? UUID()
        self.orderNumber = order.orderNumber ?? ""
        self.orderType = order.orderType ?? ""
        self.status = order.status ?? ""
        self.totalAmount = order.totalAmount
        self.orderDate = order.orderDate ?? Date()
        self.items = (order.order_orderItem as? Set<OrderItem>)?
            .map { OrderItemModel(orderItem: $0) }
            .sorted { $0.productID?.uuidString ?? "" < $1.productID?.uuidString ?? "" } ?? []
    }

    @discardableResult
    func toEntity(in context: NSManagedObjectContext) -> Order {
        let order = Order(context: context)
        order.id = self.id
        order.orderNumber = self.orderNumber
        order.orderType = self.orderType
        order.status = self.status
        order.totalAmount = self.totalAmount
        order.orderDate = self.orderDate

        for item in items {
            let orderItem = item.toEntity(in: context)
            orderItem.orderItem_order = order
        }
        return order
    }
}

extension OrderItemModel {
    init(orderItem: OrderItem) {
        self.id = orderItem.id ?? UUID()
        self.quantity = orderItem.quantity
        self.unitPrice = orderItem.unitprice
        self.productID = orderItem.orderItem_product?.id
    }

    @discardableResult
    func toEntity(in context: NSManagedObjectContext) -> OrderItem {
        let orderItem = OrderItem(context: context)
        orderItem.id = self.id
        orderItem.quantity = self.quantity
        orderItem.unitprice = self.unitPrice
        return orderItem
    }
}
