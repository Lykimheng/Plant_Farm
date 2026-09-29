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
    @Environment(\.verticalSizeClass) private var verticalSizeClass
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
        Group {
            if verticalSizeClass == .compact {
                // a phone on its side can't spare the full breakdown's height,
                // or the bar would cover the items
                HStack(spacing: Theme.Spacing.lg) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Total incl. \(estimatedDelivery.fee.priceText) delivery")
                            .font(.system(size: 11))
                            .foregroundStyle(Theme.textTertiary)
                        totalText
                    }
                    checkoutButton
                }
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.vertical, Theme.Spacing.md)
            } else {
                VStack(spacing: Theme.Spacing.md) {
                    summaryRow(Text("Subtotal"), cart.subtotal.priceText)
                    summaryRow(Text("Delivery (\(Text(estimatedDelivery.name)))"), estimatedDelivery.fee.priceText)

                    Divider().overlay(Theme.separator)

                    HStack {
                        Text("Total")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(Theme.textPrimary)
                        Spacer()
                        totalText
                    }

                    checkoutButton
                }
                .padding(Theme.Spacing.lg)
            }
        }
        .readableWidth()
        .background(.regularMaterial)
        .overlay(alignment: .top) {
            Rectangle().fill(Theme.separator).frame(height: 0.7)
        }
    }

    private var totalText: some View {
        Text(total.priceText)
            .font(.system(size: 20, weight: .bold))
            .foregroundStyle(Theme.textPrimary)
            .contentTransition(.numericText())
    }

    private var checkoutButton: some View {
        Button(user.isLoggedIn ? "Checkout" : "Sign in to checkout") {
            router.push(.checkout)
        }
        .buttonStyle(.primary)
    }

    private func summaryRow(_ label: Text, _ value: String) -> some View {
        HStack {
            label
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
