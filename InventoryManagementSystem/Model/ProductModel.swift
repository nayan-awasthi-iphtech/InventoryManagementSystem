//
//  ProductModel.swift
//  InventoryManagementSystem
//
//  Created by iPHTech 30 on 17/08/26.
//

import Foundation
import CoreData

struct ProductModel {
    let id: UUID
    var name: String
    var price: Double
    var quantity: Int32
    var sku: String
    var barcode: String
    var detail: String
    var imageData: Data?
}

extension ProductModel {
    init(product: Product) {
        self.id = product.id ?? UUID()
        self.name = product.name ?? ""
        self.price = product.price
        self.quantity = product.quantity
        self.sku = product.sku ?? ""
        self.barcode = product.barcode ?? ""
        self.detail = product.detail ?? ""
        self.imageData = product.imageData
    }

    @discardableResult
    func toEntity(in context: NSManagedObjectContext) -> Product {
        let product = Product(context: context)
        product.id = self.id
        product.name = self.name
        product.price = self.price
        product.quantity = self.quantity
        product.sku = self.sku
        product.barcode = self.barcode
        product.detail = self.detail
        product.imageData = self.imageData
        return product
    }
}
