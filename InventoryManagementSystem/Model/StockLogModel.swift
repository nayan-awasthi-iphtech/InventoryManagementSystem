//
//  StockLogModel.swift
//  InventoryManagementSystem
//
//  Created by iPHTech 30 on 17/08/26.
//

import Foundation
import CoreData

struct StockLogModel {
    let id: UUID
    var date: Date
    var previousQuantity: Int32
    var newQuantity: Int32
    var quantityChanged: Int32
    var transactionType: String
}

extension StockLogModel {
    init(stockLog: StockLog) {
        self.id = stockLog.id ?? UUID()
        self.date = stockLog.date ?? Date()
        self.previousQuantity = stockLog.previousQuantity
        self.newQuantity = stockLog.newQuantity
        self.quantityChanged = stockLog.quantityChanged
        self.transactionType = stockLog.transactionType ?? ""
    }

    @discardableResult
    func toEntity(in context: NSManagedObjectContext) -> StockLog {
        let stockLog = StockLog(context: context)
        stockLog.id = self.id
        stockLog.date = self.date
        stockLog.previousQuantity = self.previousQuantity
        stockLog.newQuantity = self.newQuantity
        stockLog.quantityChanged = self.quantityChanged
        stockLog.transactionType = self.transactionType
        return stockLog
    }
}
