//
//  OrderCard.swift
//  PP
//
//  Created by Ly Kimheng on 8/6/26.
//

import SwiftUI

struct OrderCard: View {
    let order: OrderModel

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(verbatim: "#\(order.orderNumber)")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Theme.textPrimary)
                    Text(order.placedAt, format: Date.FormatStyle(date: .abbreviated, time: .shortened))
                        .font(.system(size: 11.5))
                        .foregroundStyle(Theme.textTertiary)
                }

                Spacer()

                OrderStatusBadge(status: order.status)
            }

            Divider().overlay(Theme.separator)

            HStack(spacing: Theme.Spacing.sm) {
                ForEach(order.items.prefix(3)) { item in
                    RemoteImage(urlString: item.plant.image)
                        .scaledToFill()
                        .frame(width: 46, height: 46)
                        .clipped()
                        .background(Theme.surfaceAlt)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.sm, style: .continuous))
                }

                if order.items.count > 3 {
                    Text("+\(order.items.count - 3)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Theme.textSecondary)
                        .frame(width: 46, height: 46)
                        .background(Theme.surfaceAlt, in: RoundedRectangle(cornerRadius: Theme.Radius.sm, style: .continuous))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("^[\(order.itemCount) item](inflect: true)")
                        .font(.system(size: 11.5))
                        .foregroundStyle(Theme.textTertiary)
                    Text(order.total.priceText)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Theme.brand)
                }
            }
        }
        .cardSurface(padding: Theme.Spacing.lg)
        .accessibilityElement(children: .combine)
    }
}

struct OrderStatusBadge: View {
    let status: OrderModel.OrderStatus
    var size: CGFloat = 11.5

    var body: some View {
        Label(status.label, systemImage: status.icon)
            .font(.system(size: size, weight: .semibold))
            .foregroundStyle(status.color)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(status.color.opacity(0.14), in: Capsule())
    }
}

#Preview {
    OrderCard(order: OrderModel(
        apiId: 1, orderNumber: "PF-98234", placedAt: Date(), status: .preparing,
        items: [CartItem(plant: .preview, quantity: 2)],
        total: 63, deliveryAddress: "Phnom Penh"
    ))
    .padding()
    .background(Theme.background)
}
