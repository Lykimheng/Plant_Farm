//
//  WishlistCard.swift
//  PP
//
//  Created by Ly Kimheng on 8/6/26.
//

import SwiftUI

struct WishlistCard: View {
    let plant: PlantModel

    @EnvironmentObject private var wishlist: WishlistStore
    @EnvironmentObject private var cart: CartStore

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            RemoteImage(urlString: plant.image)
                .scaledToFill()
                .frame(height: 138)
                .frame(maxWidth: .infinity)
                .clipped()
                .background(Theme.surfaceAlt)
                .overlay(alignment: .topTrailing) { removeButton }

            VStack(alignment: .leading, spacing: 6) {
                Text(plant.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)
                    .lineLimit(1)

                RatingView(rating: plant.rating, reviewsCount: plant.counting)

                PriceLabel(price: plant.price, size: 15)

                Button {
                    cart.add(plant)
                } label: {
                    Label("Add to cart", systemImage: Icons.cart)
                        .font(.system(size: 12.5, weight: .semibold))
                        .foregroundStyle(Theme.onBrand)
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background(Theme.brand, in: RoundedRectangle(cornerRadius: Theme.Radius.sm, style: .continuous))
                }
                .buttonStyle(.pressable)
            }
            .padding(Theme.Spacing.md)
        }
        .cardBackground()
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg, style: .continuous))
    }

    private var removeButton: some View {
        Button {
            withAnimation { wishlist.remove(plant) }
        } label: {
            Image(systemName: Icons.close)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Theme.danger)
                .frame(width: 28, height: 28)
                .background(.ultraThinMaterial, in: Circle())
        }
        .buttonStyle(.pressable)
        .padding(8)
        .accessibilityLabel("Remove \(plant.name) from wishlist")
    }
}

#Preview {
    WishlistCard(plant: .preview)
        .frame(width: 180)
        .padding()
        .background(Theme.background)
        .environmentObject(WishlistStore())
        .environmentObject(CartStore())
}
