//
//  RootTabView.swift
//  InventoryManagementSystem
//
//  Created by iPHTech 30 on 06/08/26.
//

import SwiftUI
import CoreData

struct RootTabView: View {
    
    enum AppTab: Hashable {
        case dashboard, products, categories, suppliers, orders
    }
    
    @State private var selectedTab: AppTab = .dashboard
    @State private var supplierSection: SupplierListView.Ordercategories = .supplier
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardScreenView(
                onShowSuppliers: {
                    supplierSection = .supplier
                    selectedTab = .suppliers
                },
                onShowDistributors: {
                    supplierSection = .distributer
                    selectedTab = .suppliers
                }
            )
            .tabItem {
                Label("Dashboard", systemImage: "house.fill")
            }
            .tag(AppTab.dashboard)
            
            ProductListView()
                .tabItem {
                    Label("Products", systemImage: "cube.box.fill")
                }
                .tag(AppTab.products)
            
            CategoryListView()
                .tabItem {
                    Label("Categories", systemImage: "rectangle.stack.badge.person.crop")
                }
                .tag(AppTab.categories)
            
            SupplierListView(section: $supplierSection)
                .tabItem {
                    Label("Suppliers", systemImage: "person.crop.circle.fill")
                }
                .tag(AppTab.suppliers)
            
            OrderListView()
                .tabItem {
                    Label("Orders", systemImage: "cart.fill")
                }
                .tag(AppTab.orders)
        }
        .tint(.blue)
    }
}

#Preview {
    RootTabView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}