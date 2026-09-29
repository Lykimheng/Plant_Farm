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
    /// The artwork's own shape (344 × 193); it has text right up to its edges, so it
    /// must not be cropped to a wider strip.
    private static let aspectRatio: CGFloat = 344 / 193

    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var index = 0
    @State private var isVisible = false

    /// Past this height (a phone on its side, iPad) the banner stops growing and
    /// sits centred, rather than filling the screen.
    private var maxHeight: CGFloat { verticalSizeClass == .compact ? 200 : 320 }

    var body: some View {
        TabView(selection: $index) {
            ForEach(Array(Self.banners.enumerated()), id: \.offset) { position, banner in
                RemoteImage(urlString: API.bannerURL(banner))
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .tag(position)
                    .accessibilityLabel("Promotion \(position + 1) of \(Self.banners.count)")
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .aspectRatio(Self.aspectRatio, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg, style: .continuous))
        .overlay(alignment: .bottom) { indicator }
        .frame(maxWidth: maxHeight * Self.aspectRatio)
        .frame(maxWidth: .infinity)
        .onAppear { isVisible = true }
        .onDisappear { isVisible = false }
        .task(id: isVisible) {
            guard isVisible else { return }
            // one wake-up per slide instead of fifty per second
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(Self.slideDuration))
                guard !Task.isCancelled else { return }
                withAnimation(.easeInOut(duration: 0.4)) {
                    index = (index + 1) % Self.banners.count
                }
            }
        }
    }

    private var indicator: some View {
        HStack(spacing: 6) {
            ForEach(Self.banners.indices, id: \.self) { position in
                Capsule()
                    .fill(Color.white.opacity(position == index ? 1 : 0.45))
                    .frame(width: position == index ? 22 : 7, height: 7)
                    .animation(.easeInOut(duration: 0.25), value: index)
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
