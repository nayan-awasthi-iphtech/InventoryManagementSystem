//
//  BarcodeScannerView.swift
//  InventoryManagementSystem
//
//  Created by iPHTech 30 on 18/08/26.
//

import SwiftUI
import CoreData

struct BarcodeScannerView: View {
    
    @StateObject private var productViewModel = ProductViewModel()
    
    @State private var manualBarcode: String = ""
    @State private var scannedProduct: Product?
    @State private var showNotFound: Bool = false
    
    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                viewfinder
                
                manualEntrySection
                
                Spacer()
            }
            .padding(16)
        }
        .navigationTitle("Barcode Scanner")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var viewfinder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.85))
            
            Image(systemName: "viewfinder")
                .font(.system(size: 60))
                .foregroundStyle(AppTheme.accent)
        }
        .frame(height: 260)
    }
    
    private var manualEntrySection: some View {
        VStack(spacing: 14) {
            TextField("Enter barcode", text: $manualBarcode)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(.horizontal, 12)
                .frame(height: 46)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppTheme.cardBackground)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                )
            
            Button {
                findProduct()
            } label: {
                Text("Find Product")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .background(AppTheme.accent)
                    .clipShape(Capsule())
            }
            .disabled(manualBarcode.trimmingCharacters(in: .whitespaces).isEmpty)
            
            if let scannedProduct = scannedProduct {
                NavigationLink {
                    ProductDetailPage(product: scannedProduct)
                } label: {
                    HStack(spacing: 10) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(scannedProduct.name ?? "Unnamed Product")
                                .font(.headline)
                                .foregroundStyle(AppTheme.primaryText)
                                .lineLimit(1)
                            
                            Text("Barcode: \(scannedProduct.barcode ?? "N/A")")
                                .font(.caption)
                                .foregroundStyle(AppTheme.secondaryText)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(AppTheme.success)
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(AppTheme.cardBackground)
                    )
                }
                .buttonStyle(.plain)
            } else if showNotFound {
                Text("No product found for this barcode.")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.danger)
            }
        }
    }
    
    private func findProduct() {
        let trimmed = manualBarcode.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        scannedProduct = productViewModel.products.first {
            $0.barcode?.lowercased() == trimmed.lowercased()
        }
        showNotFound = scannedProduct == nil
    }
}

#Preview {
    NavigationStack {
        BarcodeScannerView()
    }
}