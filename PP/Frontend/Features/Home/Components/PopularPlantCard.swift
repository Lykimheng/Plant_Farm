//
//  PopularPlantCard.swift
//  PP
//
//  Created by Ly Kimheng on 12/8/26.
//

import SwiftUI

struct PopularPlantCard: View {
    let plant: PlantModel

    @EnvironmentObject private var cart: CartStore

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            RemoteImage(urlString: plant.image)
                .scaledToFill()
                .frame(width: 104, height: 104)
                .clipped()
                .background(Theme.surfaceAlt)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous))

            VStack(alignment: .leading, spacing: 5) {
                Text(plant.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)
                    .lineLimit(2)

                HStack(spacing: 5) {
                    RemoteImage(
                        urlString: API.categoryIconURL(plant.typePlant),
                        showsPlaceholderBackground: false
                    )
                    .scaledToFit()
                    .frame(width: 14, height: 14)

                    Text(plant.type)
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.textTertiary)
                        .lineLimit(1)
                }

                RatingView(rating: plant.rating, reviewsCount: plant.counting)

                Spacer(minLength: 2)

                PriceLabel(price: plant.price, size: 17)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack {
                WishlistToggleButton(plant: plant, style: .inline)
                Spacer(minLength: 0)
                addButton
            }
        }
        .padding(Theme.Spacing.md)
        .frame(height: 132)
        .cardBackground()
    }

    private var addButton: some View {
        Button {
            cart.add(plant)
        } label: {
            Image(systemName: Icons.plus)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Theme.onBrand)
                .frame(width: 32, height: 32)
                .background(Theme.brand, in: Circle())
                .softShadow(radius: 6, y: 3)
        }
        .buttonStyle(.pressable)
        .accessibilityLabel("Add \(plant.name) to cart")
    }
}

#Preview {
    PopularPlantCard(plant: .preview)
        .padding()
        .background(Theme.background)
        .environmentObject(CartStore())
        .environmentObject(WishlistStore())
}
