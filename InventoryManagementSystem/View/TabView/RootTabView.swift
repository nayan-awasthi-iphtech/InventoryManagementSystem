//
//  RootTabView.swift
//  InventoryManagementSystem
//
//  Created by iPHTech 30 on 06/08/26.
//

import SwiftUI
import CoreData

struct RootTabView: View {
    var body: some View {
        TabView {
            DashboardScreenView()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }

            ProductListView()
                .tabItem {
                    Label("Products", systemImage: "cube.box.fill")
                }
            CategoryListView()
                .tabItem {
                    Label("Categories", systemImage: "rectangle.stack.badge.person.crop")
                }
        }
        .tint(.blue)
    }
}

#Preview {
    RootTabView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
