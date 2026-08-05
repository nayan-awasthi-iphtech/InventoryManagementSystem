//
//  InventoryManagementSystemApp.swift
//  InventoryManagementSystem
//
//  Created by iPHTech 30 on 05/08/26.
//

import SwiftUI
import CoreData

@main
struct InventoryManagementSystemApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
