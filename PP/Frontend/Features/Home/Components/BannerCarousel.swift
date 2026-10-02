//
//  BannerCarousel.swift
//  PP
//
//  Created by Ly Kimheng on 22/1/26.
//

import SwiftUI

struct BannerCarousel: View {
    private static let banners = ["photo1", "photo2", "photo3", "photo4"]
    private static let slideDuration: TimeInterval = 4
    // the artwork's own shape; its text runs to the edges, so it's never cropped
    private static let aspectRatio: CGFloat = 344 / 193

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var position: Int? = 0
    @State private var isVisible = false

    // side by side on wide screens, so the row fills the width without cropping
    private var columns: Int {
        horizontalSizeClass == .regular || verticalSizeClass == .compact ? 2 : 1
    }

    private var lastPosition: Int { Self.banners.count - columns }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Theme.Spacing.md) {
                ForEach(Self.banners.indices, id: \.self) { index in
                    RemoteImage(urlString: API.bannerURL(Self.banners[index]))
                        .scaledToFill()
                        .containerRelativeFrame(.horizontal, count: columns, spacing: Theme.Spacing.md)
                        .frame(maxHeight: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg, style: .continuous))
                        .id(index)
                        .accessibilityLabel("Promotion \(index + 1) of \(Self.banners.count)")
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
        .scrollPosition(id: $position)
        .aspectRatio(Self.aspectRatio * CGFloat(columns), contentMode: .fit)
        .overlay(alignment: .bottom) {
            if columns == 1 { indicator }
        }
        .onAppear { isVisible = true }
        .onDisappear { isVisible = false }
        .task(id: isVisible) {
            guard isVisible else { return }
            // one wake-up per slide instead of fifty per second
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(Self.slideDuration))
                guard !Task.isCancelled else { return }
                let current = position ?? 0
                withAnimation(.easeInOut(duration: 0.4)) {
                    position = current >= lastPosition ? 0 : current + 1
                }
            }
        }
    }

    private var indicator: some View {
        HStack(spacing: 6) {
            ForEach(Self.banners.indices, id: \.self) { index in
                Capsule()
                    .fill(Color.white.opacity(index == (position ?? 0) ? 1 : 0.45))
                    .frame(width: index == (position ?? 0) ? 22 : 7, height: 7)
                    .animation(.easeInOut(duration: 0.25), value: position)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial, in: Capsule())
        .padding(.bottom, Theme.Spacing.md)
        .accessibilityHidden(true)
    }
}

#Preview {
    BannerCarousel()
        .padding()
        .background(Theme.background)
}
