//
//  CheckoutViewModel.swift
//  PP
//
//  Created by Ly Kimheng on 17/6/26.
//

import SwiftUI
import Combine

@MainActor
final class CheckoutViewModel: ObservableObject {
    @Published var selectedDelivery: DeliveryOption = .standard
    @Published var selectedPayment: PaymentMethod = PaymentMethod.all[0]
    @Published var specialNotes = ""
    @Published var contactPhone = ""
    @Published var addressOverride = ""
    @Published private(set) var isPlacingOrder = false
    @Published private(set) var errorMessage: LocalizedStringResource?
    @Published var placedOrder: OrderModel?

    let deliveryOptions = DeliveryOption.all
    let paymentMethods = PaymentMethod.all

    var deliveryFee: Double { selectedDelivery.fee }

    func total(subtotal: Double) -> Double { subtotal + deliveryFee }

    func deliveryAddress(from resolved: String) -> String {
        addressOverride.isBlank ? resolved : addressOverride.trimmed
    }

    func canPlaceOrder(cart: CartStore, address: String) -> Bool {
        !cart.isEmpty && !isPlacingOrder && !deliveryAddress(from: address).isBlank
    }
    func placeOrder(cart: CartStore, orders: OrdersStore, userId: Int, address: String) async {
        guard !isPlacingOrder else { return }

        let deliveryTo = deliveryAddress(from: address)
        guard !cart.isEmpty, !deliveryTo.isBlank else {
            errorMessage = "Add a delivery address before placing the order."
            return
        }

        isPlacingOrder = true
        errorMessage = nil
        defer { isPlacingOrder = false }

        do {
            let order = try await orders.placeOrder(
                userId: userId,
                orderNumber: OrderNumber.generate(),
                items: cart.items,
                total: total(subtotal: cart.subtotal),
                deliveryAddress: deliveryTo
            )
            cart.clear()
            placedOrder = order
        } catch {
            errorMessage = error.userMessage
            AppLog.network("place order", error)
        }
    }
}
