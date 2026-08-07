//
//  ProductListView.swift
//  InventoryManagementSystem
//
//  Created by iPHTech 30 on 06/08/26.
//

import SwiftUI
import CoreData

struct ProductListView: View {
    
    @StateObject var productViewModel = ProductViewModel()

    @State private var showAddSheet: Bool = false

    var body: some View {
        NavigationStack {
            Group {
                if productViewModel.products.isEmpty {
                    ContentUnavailableView(
                        "No Products",
                        systemImage: "cube.box",
                        description: Text("Tap + to add your first product.")
                    )
                } else {
                    List {
                        ForEach(productViewModel.products) { product in
                            NavigationLink(destination: ProductDetailPage(product: product).environmentObject(productViewModel)){
                                ProductRow(product: product)
                            }
                        }
                        .onDelete(perform: productViewModel.deleteProducts)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Products")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddEditProductView()
                    .environmentObject(productViewModel)
            }
            .onAppear{
                productViewModel.fetchProducts()
            }
        }
    }
}

private struct ProductRow: View {
    @ObservedObject var product: Product

    var body: some View {
        HStack(spacing: 12) {
            Group {
                if let data = product.imageData, let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue.opacity(0.15))
                        .overlay(
                            Image(systemName: "cube.fill")
                                .foregroundStyle(.blue)
                        )
                }
            }
            .frame(width: 48, height: 48)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(product.name ?? "Unnamed Product")
                    .font(.headline)
                    .lineLimit(1)

                Text(product.product_category?.name ?? "No Category")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(product.price.formatted(.currency(code: "INR")))
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text("Qty: \(product.quantity)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(product.quantity > 0 ? .green : .red)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ProductListView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
