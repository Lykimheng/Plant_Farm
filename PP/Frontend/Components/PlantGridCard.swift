//
//  PlantGridCard.swift
//  PP
//
//  Created by Ly Kimheng on 7/8/26.
//

import SwiftUI

struct PlantGridCard: View {
    let listing: PlantListing
    var imageHeight: CGFloat = 150

    @EnvironmentObject private var cart: CartStore

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            image
            details
        }
        .cardBackground()
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg, style: .continuous))
        .overlay(alignment: .topLeading) { discountBadge }
        .overlay(alignment: .topTrailing) { WishlistToggleButton(plant: listing.plant, style: .overlay).padding(9) }
        .overlay(alignment: .bottomTrailing) { addButton.padding(11) }
        .contentShape(Rectangle())
        .accessibilityElement(children: .contain)
    }

    // MARK: - Pieces

    private var image: some View {
        RemoteImage(urlString: listing.image)
            .scaledToFill()
            .frame(maxWidth: .infinity)
            .frame(height: imageHeight)
            .clipped()
            .background(Theme.surfaceAlt)
    }

    @ViewBuilder
    private var discountBadge: some View {
        if listing.isDiscounted {
            Text("-\(listing.discountPercentage)%")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Theme.onBrand)
                .padding(.horizontal, 7)
                .padding(.vertical, 4)
                .background(Theme.danger, in: Capsule())
                .padding(9)
        }
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(listing.name)
                .font(.system(size: 14.5, weight: .semibold))
                .foregroundStyle(Theme.textPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(height: 38, alignment: .topLeading)

            HStack(spacing: 5) {
                RemoteImage(
                    urlString: API.categoryIconURL(listing.typePlant),
                    showsPlaceholderBackground: false
                )
                .scaledToFit()
                .frame(width: 14, height: 14)

                Text(listing.type)
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.textTertiary)
                    .lineLimit(1)
            }

            RatingView(rating: listing.plant.rating, reviewsCount: listing.plant.counting)

            PriceLabel(price: listing.price, originalPrice: listing.originalPrice)
                .padding(.trailing, 38)
                .padding(.top, 1)
        }
        .padding(11)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var addButton: some View {
        Button {
            cart.add(listing.purchasable)
        } label: {
            Image(systemName: Icons.plus)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Theme.onBrand)
                .frame(width: 32, height: 32)
                .background(Theme.brand, in: Circle())
                .softShadow(radius: 6, y: 3)
        }
        .buttonStyle(.pressable)
        .accessibilityLabel("Add \(listing.name) to cart")
    }
}

// MARK: - Price

struct PriceLabel: View {
    let price: Double
    var originalPrice: Double?
    var size: CGFloat = 16

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text(price.priceText)
                .font(.system(size: size, weight: .bold))
                .foregroundStyle(Theme.textPrimary)

            if let originalPrice {
                Text(originalPrice.priceText)
                    .font(.system(size: size * 0.75))
                    .foregroundStyle(Theme.textTertiary)
                    .strikethrough(true, color: Theme.textTertiary)
            }
        }
        .lineLimit(1)
        .minimumScaleFactor(0.75)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            originalPrice == nil
            ? price.priceText
            : "\(price.priceText), reduced from \(originalPrice!.priceText)"
        )
    }
}

// MARK: - Wishlist toggle

struct WishlistToggleButton: View {
    enum Style {
        case overlay
        case inline
        case prominent

        var diameter: CGFloat {
            switch self {
            case .overlay, .inline: return 30
            case .prominent:        return 40
            }
        }

        var iconSize: CGFloat {
            switch self {
            case .overlay, .inline: return 13
            case .prominent:        return 15
            }
        }
    }

    let plant: PlantModel
    var style: Style = .inline

    @EnvironmentObject private var wishlist: WishlistStore

    private var isSaved: Bool { wishlist.contains(plant) }

    var body: some View {
        Button {
            withAnimation(.easeOut(duration: 0.2)) {
                wishlist.toggle(plant)
            }
        } label: {
            Image(systemName: isSaved ? Icons.favoriteFilled : Icons.favorite)
                .font(.system(size: style.iconSize, weight: .semibold))
                .foregroundStyle(isSaved ? Theme.danger : Theme.textPrimary)
                .frame(width: style.diameter, height: style.diameter)
                .background(background)
        }
        .buttonStyle(.pressable)
        .accessibilityLabel(isSaved ? "Remove \(plant.name) from wishlist" : "Save \(plant.name) to wishlist")
    }

    @ViewBuilder
    private var background: some View {
        switch style {
        case .overlay:
            Circle().fill(.ultraThinMaterial)
        case .inline:
            Circle().fill(Theme.surfaceAlt)
        case .prominent:
            Circle()
                .fill(Theme.surface.opacity(0.92))
                .overlay(Circle().strokeBorder(Theme.separator, lineWidth: 0.7))
        }
    }
}

#Preview {
    HStack(spacing: 16) {
        PlantGridCard(listing: PlantModel.preview.listing)
        PlantGridCard(listing: PlantListing(.preview, discountPrice: 18))
    }
    .padding()
    .background(Theme.background)
    .environmentObject(CartStore())
    .environmentObject(WishlistStore())
}
