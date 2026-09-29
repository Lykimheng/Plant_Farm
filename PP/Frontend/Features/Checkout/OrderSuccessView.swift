//
//  OrderSuccessView.swift
//  PP
//
//  Created by Ly Kimheng on 30/4/26.
//

import SwiftUI

struct OrderSuccessView: View {
    let order: OrderModel

    @EnvironmentObject private var user: UserStore
    @EnvironmentObject private var router: AppRouter

    @State private var animateCheck = false
    @State private var animateContent = false

    private var shipmentDescription: Text {
        guard let first = order.items.first else { return Text("Your order") }
        let others = order.items.count - 1
        return others > 0 ? Text("\(first.plant.name) and \(others) more") : Text(first.plant.name)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.xl) {
                successMark
                headline
                details
                actions
                confirmationNote
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.bottom, Theme.Spacing.xxl)
            .readableWidth(Theme.Layout.compact)
        }
        .background(
            LinearGradient(
                colors: [Theme.brandTint, Theme.background],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .task {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.15)) {
                animateCheck = true
            }
            withAnimation(.easeOut(duration: 0.45).delay(0.4)) {
                animateContent = true
            }
        }
    }

    // MARK: - Pieces

    private var successMark: some View {
        ZStack {
            Circle()
                .stroke(Theme.brand.opacity(0.18), lineWidth: 12)
                .frame(width: 148, height: 148)

            Circle()
                .fill(Theme.brandTint)
                .frame(width: 118, height: 118)

            Image(systemName: Icons.checkmark)
                .font(.system(size: 50, weight: .bold))
                .foregroundStyle(Theme.brand)
                .scaleEffect(animateCheck ? 1 : 0.3)
                .opacity(animateCheck ? 1 : 0)
        }
        .padding(.top, Theme.Spacing.xxl)
        .accessibilityHidden(true)
    }

    private var headline: some View {
        VStack(spacing: Theme.Spacing.sm) {
            Text("Order placed")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Theme.textPrimary)

            Text("Your green companions are being prepared for the journey to your home.")
                .font(.system(size: 14))
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 16)
    }

    private var details: some View {
        VStack(spacing: Theme.Spacing.md) {
            infoRow(icon: "number", label: Text("Order number"), value: Text(verbatim: "#\(order.orderNumber)"))
            infoRow(icon: Icons.truck, label: Text("Estimated delivery"), value: Text("2–3 business days"))
            infoRow(icon: Icons.bag, label: shipmentDescription, value: Text(order.total.priceText))
        }
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 16)
    }

    private func infoRow(icon: String, label: Text, value: Text) -> some View {
        HStack(spacing: Theme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Theme.brand)
                .frame(width: 42, height: 42)
                .background(Theme.brandTint, in: RoundedRectangle(cornerRadius: Theme.Radius.sm, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                label
                    .textCase(.uppercase)
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(0.5)
                    .foregroundStyle(Theme.textTertiary)
                    .lineLimit(1)
                value
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)
            }

            Spacer(minLength: 0)
        }
        .cardSurface(padding: Theme.Spacing.md)
        .accessibilityElement(children: .combine)
    }

    private var actions: some View {
        VStack(spacing: Theme.Spacing.md) {
            Button("Track order") { router.push(.orderDetail(order)) }
                .buttonStyle(.primary)

            Button("Continue shopping") { router.returnToShop() }
                .buttonStyle(.secondary)
        }
        .opacity(animateContent ? 1 : 0)
    }

    private var confirmationNote: some View {
        Text(user.email.isBlank
             ? "You can follow this order from Profile → My Orders."
             : "A confirmation was sent to \(user.email).")
            .font(.system(size: 12))
            .foregroundStyle(Theme.textTertiary)
            .multilineTextAlignment(.center)
            .opacity(animateContent ? 1 : 0)
    }
}

#Preview {
    NavigationStack {
        OrderSuccessView(
            order: OrderModel(
                apiId: 1,
                orderNumber: "PF-98241",
                placedAt: Date(),
                status: .pending,
                items: [CartItem(plant: .preview, quantity: 2)],
                total: 51.50,
                deliveryAddress: "No. 42, St. 271, Phnom Penh"
            )
        )
        .environmentObject(OrdersStore())
        .environmentObject(UserStore())
        .environmentObject(LocationManager())
        .environmentObject(AppRouter())
    }
}
