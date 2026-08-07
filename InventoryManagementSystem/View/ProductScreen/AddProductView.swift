//
//  AddProductView.swift
//  InventoryManagementSystem
//
//  Created by iPHTech 30 on 06/08/26.
//

import SwiftUI
import CoreData

struct AddProductView: View {

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)],
        animation: .default
    )
    private var categories: FetchedResults<Category>

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Supplier.name, ascending: true)],
        animation: .default
    )
    private var suppliers: FetchedResults<Supplier>

    @State private var name: String = ""
    @State private var sku: String = ""
    @State private var barcode: String = ""
    @State private var price: String = ""
    @State private var quantity: String = ""
    @State private var detail: String = ""
    @State private var selectedCategory: Category?
    @State private var selectedSupplier: Supplier?

    private var validCheck: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Product Details") {
                    TextField("Product Name", text: $name)
                    TextField("SKU", text: $sku)
                        .textInputAutocapitalization(.characters)
                    TextField("Barcode", text: $barcode)
                        .keyboardType(.numberPad)
                    TextField("Price", text: $price)
                        .keyboardType(.decimalPad)
                    Stepper(value: Binding(
                        get: { Int32(quantity) ?? 0 },
                        set: { quantity = String($0) }
                    ), in: 0...10000) {
                        Text("Quantity: \(Int32(quantity) ?? 0)")
                    }
                }

                Section("Classification") {
                    Picker("Category", selection: $selectedCategory) {
                        Text("None").tag(Category?.none)
                        ForEach(categories) { category in
                            Text(category.name ?? "Unnamed").tag(Category?.some(category))
                        }
                    }
                    Picker("Supplier", selection: $selectedSupplier) {
                        Text("None").tag(Supplier?.none)
                        ForEach(suppliers) { supplier in
                            Text(supplier.name ?? "Unnamed").tag(Supplier?.some(supplier))
                        }
                    }
                }

                Section("Description") {
                    TextField("Product description", text: $detail, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Add Product")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { saveProduct() }
                        .fontWeight(.bold)
                        .disabled(!validCheck)
                }
            }
        }
    }

    private func saveProduct() {
        let product = Product(context: viewContext)
        product.id = UUID()
        product.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        product.sku = sku
        product.barcode = barcode
        product.price = Double(price) ?? 0
        product.quantity = Int32(quantity) ?? 0
        product.detail = detail
        product.product_category = selectedCategory
        product.product_Supplier = selectedSupplier
        try? viewContext.save()
        dismiss()
    }
}

#Preview {
    AddProductView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
