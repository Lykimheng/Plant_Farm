//
//  CheckoutView.swift
//  PP
//
//  Created by Ly Kimheng on 26/12/25.
//

import SwiftUI

struct CheckoutView: View {
    @StateObject private var viewModel = CheckoutViewModel()
    @EnvironmentObject private var cart: CartStore
    @EnvironmentObject private var user: UserStore
    @EnvironmentObject private var location: LocationManager
    @EnvironmentObject private var orders: OrdersStore
    @EnvironmentObject private var router: AppRouter

    @State private var isEditingAddress = false

    private var resolvedAddress: String {
        location.userAddress.isBlank ? user.location : location.userAddress
    }

    private var deliveryAddress: String {
        viewModel.deliveryAddress(from: resolvedAddress)
    }

    var body: some View {
        Group {
            if !user.isLoggedIn {
                SignInRequiredView(message: "Sign in to check out and place your order.")
            } else if cart.isEmpty {
                EmptyStateView(
                    icon: "cart",
                    title: "Nothing to check out",
                    message: "Your cart is empty."
                )
            } else {
                content
            }
        }
        .background(Theme.background)
        .navigationTitle("Checkout")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .task { location.requestPermissionIfNeeded() }
        .onChange(of: viewModel.placedOrder) { _, order in
            guard let order else { return }
            router.push(.orderPlaced(order))
        }
    }

    private var content: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.lg) {
                mapPreview
                addressCard
                deliveryOptions
                paymentMethods
                specialNotes
                orderSummary

                InlineError(message: viewModel.errorMessage)
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.vertical, Theme.Spacing.lg)
            .readableWidth()
        }
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom) { confirmBar }
    }

    // MARK: - Map

    @ViewBuilder
    private var mapPreview: some View {
        if let coordinate = location.userLocation {
            AppleMapView(coordinate: coordinate)
                .frame(height: 180)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg, style: .continuous))
        } else {
            RoundedRectangle(cornerRadius: Theme.Radius.lg, style: .continuous)
                .fill(Theme.surfaceAlt)
                .frame(height: 180)
                .overlay {
                    VStack(spacing: Theme.Spacing.sm) {
                        if location.isDenied {
                            Image(systemName: "location.slash")
                                .font(.system(size: 22))
                                .foregroundStyle(Theme.textTertiary)
                            Text("Location is off — type your address below.")
                                .font(.system(size: 12))
                                .foregroundStyle(Theme.textTertiary)
                                .multilineTextAlignment(.center)
                        } else {
                            ProgressView()
                            Text("Finding your location…")
                                .font(.system(size: 12))
                                .foregroundStyle(Theme.textTertiary)
                        }
                    }
                    .padding(Theme.Spacing.lg)
                }
        }
    }

    // MARK: - Address

    private var addressCard: some View {
        SectionCard(title: "Delivery Address", icon: Icons.location) {
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                if isEditingAddress {
                    AppTextField(
                        placeholder: "Street, house, floor",
                        text: $viewModel.addressOverride,
                        icon: Icons.location,
                        textContentType: .fullStreetAddress,
                        submitLabel: .done
                    )
                    AppTextField(
                        placeholder: "Contact phone",
                        text: $viewModel.contactPhone,
                        icon: Icons.phone,
                        textContentType: .telephoneNumber,
                        submitLabel: .done
                    )
                } else {
                    (deliveryAddress.isBlank ? Text("No address yet") : Text(deliveryAddress))
                        .font(.system(size: 14))
                        .foregroundStyle(deliveryAddress.isBlank ? Theme.textTertiary : Theme.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    if !viewModel.contactPhone.isBlank {
                        Label(viewModel.contactPhone, systemImage: Icons.phone)
                            .font(.system(size: 12.5))
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
            }
        } accessory: {
            Button(isEditingAddress ? "Done" : "Edit") {
                withAnimation(.easeInOut(duration: 0.2)) { isEditingAddress.toggle() }
            }
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(Theme.brand)
        }
    }

    // MARK: - Delivery

    private var deliveryOptions: some View {
        SectionCard(title: "Delivery Speed", icon: Icons.truck) {
            HStack(spacing: Theme.Spacing.md) {
                ForEach(viewModel.deliveryOptions) { option in
                    DeliveryOptionTile(
                        option: option,
                        isSelected: viewModel.selectedDelivery == option
                    ) {
                        withAnimation(.easeOut(duration: 0.15)) { viewModel.selectedDelivery = option }
                    }
                }
            }
        }
    }

    // MARK: - Payment

    private var paymentMethods: some View {
        SectionCard(title: "Payment Method", icon: Icons.card) {
            VStack(spacing: 0) {
                ForEach(viewModel.paymentMethods) { method in
                    PaymentMethodRow(
                        method: method,
                        isSelected: viewModel.selectedPayment == method
                    ) {
                        viewModel.selectedPayment = method
                    }

                    if method != viewModel.paymentMethods.last {
                        Divider().overlay(Theme.separator).padding(.leading, 56)
                    }
                }
            }
        }
    }

    // MARK: - Notes

    private var specialNotes: some View {
        SectionCard(title: "Special Notes", icon: Icons.edit) {
            ZStack(alignment: .topLeading) {
                if viewModel.specialNotes.isEmpty {
                    Text("E.g. leave with the guard, handle carefully…")
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.textTertiary)
                        .padding(.top, 8)
                        .padding(.leading, 5)
                }

                TextEditor(text: $viewModel.specialNotes)
                    .font(.system(size: 13))
                    .frame(height: 84)
                    .scrollContentBackground(.hidden)
            }
            .padding(6)
            .background(Theme.surfaceAlt, in: RoundedRectangle(cornerRadius: Theme.Radius.sm, style: .continuous))
        }
    }

    // MARK: - Summary

    private var orderSummary: some View {
        VStack(spacing: Theme.Spacing.md) {
            HStack {
                Text("Order Summary")
                    .font(.system(size: 15, weight: .bold))
                Spacer()
                Text("^[\(cart.totalCount) item](inflect: true)")
                    .font(.system(size: 13))
                    .opacity(0.8)
            }

            summaryRow(Text("Subtotal"), cart.subtotal.priceText)
            summaryRow(Text("\(Text(viewModel.selectedDelivery.name)) delivery"), viewModel.deliveryFee.priceText)

            Divider().overlay(Theme.onBrand.opacity(0.3))

            HStack {
                Text("Total")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
                Text(viewModel.total(subtotal: cart.subtotal).priceText)
                    .font(.system(size: 20, weight: .bold))
                    .contentTransition(.numericText())
            }
        }
        .foregroundStyle(Theme.onBrand)
        .padding(Theme.Spacing.lg)
        .background(Theme.brandGradient, in: RoundedRectangle(cornerRadius: Theme.Radius.lg, style: .continuous))
    }

    private func summaryRow(_ label: Text, _ value: String) -> some View {
        HStack {
            label.opacity(0.85)
            Spacer()
            Text(value)
        }
        .font(.system(size: 14))
    }

    // MARK: - Confirm

    private var confirmBar: some View {
        VStack(spacing: Theme.Spacing.sm) {
            Button {
                Task {
                    await viewModel.placeOrder(
                        cart: cart,
                        orders: orders,
                        userId: user.id,
                        address: resolvedAddress
                    )
                }
            } label: {
                if viewModel.isPlacingOrder {
                    ProgressView().tint(Theme.onBrand)
                } else {
                    Text("Place Order · \(viewModel.total(subtotal: cart.subtotal).priceText)")
                }
            }
            .buttonStyle(.primary)
            .disabled(!viewModel.canPlaceOrder(cart: cart, address: resolvedAddress))

            if deliveryAddress.isBlank {
                Text("Add a delivery address to continue")
                    .font(.system(size: 11.5))
                    .foregroundStyle(Theme.textTertiary)
            }
        }
        .padding(Theme.Spacing.lg)
        .readableWidth()
        .background(.regularMaterial)
        .overlay(alignment: .top) {
            Rectangle().fill(Theme.separator).frame(height: 0.7)
        }
    }
}

// MARK: - Rows

struct DeliveryOptionTile: View {
    let option: DeliveryOption
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 4) {
                Text(option.name)
                    .font(.system(size: 13, weight: .semibold))
                Text(option.fee.priceText)
                    .font(.system(size: 18, weight: .bold))
                Text(option.duration)
                    .font(.system(size: 11))
                    .opacity(0.8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Theme.Spacing.md)
            .foregroundStyle(isSelected ? Theme.onBrand : Theme.textPrimary)
            .background(
                isSelected ? Theme.brand : Theme.surfaceAlt,
                in: RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous)
            )
        }
        .buttonStyle(.pressable)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

struct PaymentMethodRow: View {
    let method: PaymentMethod
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Theme.Spacing.md) {
                Image(systemName: method.icon)
                    .font(.system(size: 16))
                    .foregroundStyle(Theme.brand)
                    .frame(width: 40, height: 40)
                    .background(Theme.brandTint, in: RoundedRectangle(cornerRadius: Theme.Radius.sm, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text(method.name)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Theme.textPrimary)
                    Text(method.detail)
                        .font(.system(size: 11.5))
                        .foregroundStyle(Theme.textTertiary)
                }

                Spacer()

                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .font(.system(size: 19))
                    .foregroundStyle(isSelected ? Theme.brand : Theme.textTertiary.opacity(0.6))
            }
            .padding(.vertical, Theme.Spacing.sm)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

/// Titled block used across checkout, orders and profile.
struct SectionCard<Content: View, Accessory: View>: View {
    let title: LocalizedStringResource
    var icon: String?
    @ViewBuilder var content: () -> Content
    @ViewBuilder var accessory: () -> Accessory

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack(spacing: Theme.Spacing.sm) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.brand)
                }
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                accessory()
            }

            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface(padding: Theme.Spacing.lg)
    }
}

extension SectionCard where Accessory == EmptyView {
    init(title: LocalizedStringResource, icon: String? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.init(title: title, icon: icon, content: content, accessory: { EmptyView() })
    }
}

#Preview {
    NavigationStack {
        CheckoutView()
            .environmentObject(CartStore())
            .environmentObject(UserStore())
            .environmentObject(LocationManager())
            .environmentObject(OrdersStore())
            .environmentObject(AppRouter())
    }
}
