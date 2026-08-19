//
//  QrCodeGenerator.swift
//  InventoryManagementSystem
//
//  Created by iPHTech 30 on 18/08/26.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct QrCodeGenerator {
    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()
    
    func generateQrCode(from string: String) -> UIImage? {
        let data = Data(string.utf8)
        
        filter.message = data
        filter.correctionLevel = "M"
        
        guard let outputImage = filter.outputImage else { return nil }
        
        let transformedImage = outputImage.transformed(
            by: CGAffineTransform(scaleX: 10, y: 10)
        )
        
        guard let cgImage = context.createCGImage(
            transformedImage,
            from: transformedImage.extent
        ) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
}

