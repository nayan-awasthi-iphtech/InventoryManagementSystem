//
//  AuthModel.swift
//  InventoryManagementSystem
//
//  Created by iPHTech 30 on 17/08/26.
//

import Foundation
import CoreData

struct AuthModel {
    let id: UUID
    var name: String
    var email: String
    var password: String
    var contact: String
}

extension AuthModel {
    init(admin: Admin) {
        self.id = admin.id ?? UUID()
        self.name = admin.name ?? ""
        self.email = admin.email ?? ""
        self.password = admin.password ?? ""
        self.contact = admin.contact ?? ""
    }

    @discardableResult
    func toEntity(in context: NSManagedObjectContext) -> Admin {
        let admin = Admin(context: context)
        admin.id = self.id
        admin.name = self.name
        admin.email = self.email
        admin.password = self.password
        admin.contact = self.contact
        admin.timestamp = Date()
        return admin
    }
}
