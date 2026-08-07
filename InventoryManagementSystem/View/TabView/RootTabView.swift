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
        }
        .tint(.blue)
    }
}

#Preview {
    RootTabView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
