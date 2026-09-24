//
//  Foundation+App.swift
//  PP
//
//  Created by Ly Kimheng on 10/9/26.
//

import SwiftUI

nonisolated extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
    var isBlank: Bool { trimmed.isEmpty }
    var looksLikeEmail: Bool {
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return trimmed.range(of: pattern, options: .regularExpression) != nil
    }
}

nonisolated extension Double {
    var priceText: String {
        formatted(.currency(code: "USD").precision(.fractionLength(2)))
    }
}

nonisolated extension Error {
    var userMessage: String {
        (self as? APIError)?.message ?? "Something went wrong. Please try again."
    }
}

nonisolated extension UIImage {
    func resized(maxDimension: CGFloat) -> UIImage {
        let longestSide = max(size.width, size.height)
        guard longestSide > maxDimension else { return self }

        let scale = maxDimension / longestSide
        let target = CGSize(width: size.width * scale, height: size.height * scale)

        return UIGraphicsImageRenderer(size: target).image { _ in
            draw(in: CGRect(origin: .zero, size: target))
        }
    }
}
