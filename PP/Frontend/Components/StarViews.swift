//
//  StarViews.swift
//  PP
//
//  Created by Ly Kimheng on 7/8/26.
//

import SwiftUI

struct StarRow: View {
    let rating: Double
    var size: CGFloat = 12

    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: symbol(for: star))
                    .font(.system(size: size))
                    .foregroundStyle(Theme.star)
            }
        }
    }

    private func symbol(for star: Int) -> String {
        let value = Double(star)
        if rating >= value - 0.25 { return "star.fill" }
        if rating >= value - 0.75 { return "star.leadinghalf.filled" }
        return "star"
    }
}

struct StarRatingInput: View {
    @Binding var rating: Int
    var size: CGFloat = 34

    var body: some View {
        HStack(spacing: 10) {
            ForEach(1...5, id: \.self) { star in
                Button {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                        rating = star
                    }
                } label: {
                    Image(systemName: star <= rating ? "star.fill" : "star")
                        .font(.system(size: size))
                        .foregroundStyle(star <= rating ? Theme.star : Theme.textTertiary)
                        .scaleEffect(star == rating ? 1.12 : 1)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(star) star\(star == 1 ? "" : "s")")
            }
        }
    }
}

struct RatingBreakdown: View {
    let summary: ReviewSummary

    var body: some View {
        VStack(spacing: 4) {
            ForEach((1...5).reversed(), id: \.self) { star in
                HStack(spacing: 6) {
                    Text("\(star)")
                        .font(.system(size: 10.5))
                        .foregroundStyle(Theme.textTertiary)
                        .frame(width: 8)

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Theme.surfaceAlt)
                            Capsule()
                                .fill(Theme.star)
                                .frame(width: geo.size.width * summary.share(forStar: star))
                        }
                    }
                    .frame(height: 6)

                    Text("\(summary.count(forStar: star))")
                        .font(.system(size: 10.5))
                        .foregroundStyle(Theme.textTertiary)
                        .frame(width: 18, alignment: .trailing)
                }
            }
        }
    }
}
