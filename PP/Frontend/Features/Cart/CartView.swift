//
//  CartView.swift
//  PP
//
//  Created by Ly Kimheng on 25/12/25.
//

import SwiftUI

struct CartView: View {
    @EnvironmentObject private var cart: CartStore
    @EnvironmentObject private var user: UserStore
    @EnvironmentObject private var router: AppRouter
    private let estimatedDelivery = DeliveryOption.standard
    private var total: Double { cart.subtotal + estimatedDelivery.fee }

    var body: some View {
        Group {
            if cart.isEmpty {
                emptyState
            } else {
                cartContent
            }
        }
        .background(Theme.background)
        .navigationTitle("My Cart")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !cart.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Clear", role: .destructive) {
                        withAnimation { cart.clear() }
                    }
                    .tint(Theme.danger)
                }
            }
        }
    }

    // MARK: - Content

    private var cartContent: some View {
        ScrollView {
            LazyVStack(spacing: Theme.Spacing.md) {
                ForEach(cart.items) { item in
                    CartLineRow(
                        item: item,
                        onIncrease: { cart.increase(item.plant) },
                        onDecrease: { withAnimation { cart.decrease(item.plant) } },
                        onDelete: { withAnimation { cart.remove(item.plant) } }
                    )
                }
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.vertical, Theme.Spacing.md)
            .readableWidth()
        }
        .safeAreaInset(edge: .bottom) { summaryBar }
    }

    private var emptyState: some View {
        EmptyStateView(
            icon: "cart",
            title: "Your cart is empty",
            message: "Plants you add from the shop will show up here."
        )
        .frame(maxHeight: .infinity)
    }

    // MARK: - Summary

    private var summaryBar: some View {
        VStack(spacing: Theme.Spacing.md) {
            summaryRow("Subtotal", cart.subtotal.priceText)
            summaryRow("Delivery (\(estimatedDelivery.name.lowercased()))", estimatedDelivery.fee.priceText)

            Divider().overlay(Theme.separator)

            HStack {
                Text("Total")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                Text(total.priceText)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)
                    .contentTransition(.numericText())
            }

            Button(user.isLoggedIn ? "Checkout" : "Sign in to checkout") {
                router.push(.checkout)
            }
            .buttonStyle(.primary)
        }
        .padding(Theme.Spacing.lg)
        .readableWidth()
        .background(.regularMaterial)
        .overlay(alignment: .top) {
            Rectangle().fill(Theme.separator).frame(height: 0.7)
        }
    }

    private func summaryRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundStyle(Theme.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Theme.textPrimary)
                .contentTransition(.numericText())
        }
    }
}

#Preview {
    NavigationStack {
        CartView()
            .environmentObject(CartStore())
            .environmentObject(UserStore())
            .environmentObject(AppRouter())
    }
}
