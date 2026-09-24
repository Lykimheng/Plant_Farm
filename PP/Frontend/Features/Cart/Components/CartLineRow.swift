//
//  CartLineRow.swift
//  PP
//
//  Created by Ly Kimheng on 12/8/26.
//

import SwiftUI

struct CartLineRow: View {
    let item: CartItem
    var onIncrease: () -> Void
    var onDecrease: () -> Void
    var onDelete: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: Theme.Spacing.md) {
            RemoteImage(urlString: item.plant.image)
                .scaledToFill()
                .frame(width: 82, height: 92)
                .clipped()
                .background(Theme.surfaceAlt)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.sm, style: .continuous))

            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .top) {
                    Text(item.plant.name)
                        .font(.system(size: 14.5, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)
                        .lineLimit(2)

                    Spacer(minLength: Theme.Spacing.sm)

                    Button(action: onDelete) {
                        Image(systemName: Icons.close)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Theme.textTertiary)
                            .frame(width: 26, height: 26)
                            .background(Theme.surfaceAlt, in: Circle())
                    }
                    .buttonStyle(.pressable)
                    .accessibilityLabel("Remove \(item.plant.name) from cart")
                }

                Text("\(item.plant.price.priceText) each")
                    .font(.system(size: 11.5))
                    .foregroundStyle(Theme.textTertiary)

                Spacer(minLength: Theme.Spacing.xs)

                HStack {
                    Text(item.lineTotal.priceText)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Theme.textPrimary)
                        .contentTransition(.numericText())

                    Spacer()

                    QuantityStepper(
                        quantity: item.quantity,
                        maximum: CartStore.maximumPerLine,
                        compact: true,
                        onDecrement: onDecrease,
                        onIncrement: onIncrease
                    )
                }
            }
        }
        .padding(Theme.Spacing.md)
        .cardBackground()
    }
}

#Preview {
    CartLineRow(
        item: CartItem(plant: .preview, quantity: 2),
        onIncrease: {}, onDecrease: {}, onDelete: {}
    )
    .padding()
    .background(Theme.background)
}
