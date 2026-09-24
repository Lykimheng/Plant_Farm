//
//  RatingView.swift
//  PP
//
//  Created by Ly Kimheng on 7/8/26.
//

import SwiftUI

struct RatingView: View {
    let rating: Double
    var reviewsCount: Int?
    var starSize: CGFloat = 11
    var showsValue: Bool = true
    var onDarkBackground: Bool = false

    private var isUnrated: Bool { (reviewsCount ?? 0) == 0 && rating == 0 }

    private var valueColor: Color {
        onDarkBackground ? .white : Theme.textPrimary
    }

    private var countColor: Color {
        onDarkBackground ? .white.opacity(0.7) : Theme.textTertiary
    }

    var body: some View {
        HStack(spacing: 3) {
            if isUnrated {
                Image(systemName: "star")
                    .font(.system(size: starSize))
                    .foregroundStyle(countColor)
                Text("No ratings yet")
                    .font(.system(size: starSize))
                    .foregroundStyle(countColor)
            } else {
                Image(systemName: "star.fill")
                    .font(.system(size: starSize))
                    .foregroundStyle(Theme.star)

                if showsValue {
                    Text(String(format: "%.1f", rating))
                        .font(.system(size: starSize + 1, weight: .semibold))
                        .foregroundStyle(valueColor)
                }

                if let reviewsCount, reviewsCount > 0 {
                    Text("(\(reviewsCount))")
                        .font(.system(size: starSize))
                        .foregroundStyle(countColor)
                }
            }
        }
        .lineLimit(1)
    }
}
