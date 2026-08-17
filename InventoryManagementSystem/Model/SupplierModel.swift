//
//  SupplierModel.swift
//  InventoryManagementSystem
//
//  Created by iPHTech 30 on 17/08/26.
//

import Foundation
import CoreData

struct SupplierModel {
    let id: UUID
    var name: String
    var companyName: String
    var address: String
    var contact: String
    var gstNumber: String
    var supplierDetail: String
    var imageData: Data?
}

extension SupplierModel {
    init(supplier: Supplier) {
        self.id = supplier.id ?? UUID()
        self.name = supplier.name ?? ""
        self.companyName = supplier.companyName ?? ""
        self.address = supplier.address ?? ""
        self.contact = supplier.contact ?? ""
        self.gstNumber = supplier.gstNumber ?? ""
        self.supplierDetail = supplier.supplierDetail ?? ""
        self.imageData = supplier.imageData
    }
    @discardableResult
    func toEntity(in context: NSManagedObjectContext) -> Supplier {
        let supplier = Supplier(context: context)
        supplier.id = self.id
        supplier.name = self.name
        supplier.companyName = self.companyName
        supplier.address = self.address
        supplier.contact = self.contact
        supplier.gstNumber = self.gstNumber
        supplier.supplierDetail = self.supplierDetail
        supplier.imageData = self.imageData
        return supplier
    }
}
