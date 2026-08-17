//
//  DistributorModel.swift
//  InventoryManagementSystem
//
//  Created by iPHTech 30 on 17/08/26.
//

import Foundation
import CoreData

struct DistributorModel {
    let id: UUID
    var name: String
    var address: String
    var contact: String
    var gstNumber: String
    var imageData: Data?
}

extension DistributorModel {
    init(distributor: Distributor) {
        self.id = distributor.id ?? UUID()
        self.name = distributor.name ?? ""
        self.address = distributor.address ?? ""
        self.contact = distributor.contact ?? ""
        self.gstNumber = distributor.gstNumber ?? ""
        self.imageData = distributor.imageData
    }

    @discardableResult
    func toEntity(in context: NSManagedObjectContext) -> Distributor {
        let distributor = Distributor(context: context)
        distributor.id = self.id
        distributor.name = self.name
        distributor.address = self.address
        distributor.contact = self.contact
        distributor.gstNumber = self.gstNumber
        distributor.imageData = self.imageData
        return distributor
    }
}
