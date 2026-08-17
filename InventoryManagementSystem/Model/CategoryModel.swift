//
//  CategoryModel.swift
//  InventoryManagementSystem
//
//  Created by iPHTech 30 on 17/08/26.
//

import Foundation
import CoreData

struct CategoryModel {
    let id: UUID
    var name: String
}

extension CategoryModel {
    init(category: Category) {
        self.id = category.id ?? UUID()
        self.name = category.name ?? ""
    }

    @discardableResult
    func toEntity(in context: NSManagedObjectContext) -> Category {
        let category = Category(context: context)
        category.id = self.id
        category.name = self.name
        return category
    }
}
