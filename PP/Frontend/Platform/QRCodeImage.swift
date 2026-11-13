//
//  QRCodeImage.swift
//  PP
//
//  Created by Ly Kimheng on 3/11/26.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit

nonisolated enum QRCodeImage {
    static func make(from text: String, scale: CGFloat = 12) -> UIImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(text.utf8)
        filter.correctionLevel = "Q"

        guard let output = filter.outputImage?.transformed(by: CGAffineTransform(scaleX: scale, y: scale)),
              let cgImage = CIContext().createCGImage(output, from: output.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}
