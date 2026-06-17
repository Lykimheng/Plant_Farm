//
//  CheckoutViewModel.swift
//  PP
//
//  Created by Ly Kimheng on 17/6/26.
//

import SwiftUI
import Combine

class CheckoutViewModel: ObservableObject {
    @Published var selectedDelivery = "Standard"
    @Published var selectedPayment = "ABA Pay"
    @Published var specialNotes = ""
    @Published var orderPlaced = false
    @Published var savedItems: [CartItem] = []
    @Published var isLoading = false
    @Published var errorMessage = ""

    let deliveryOptions: [(name: String, price: Double, duration: String)] = [
        ("Standard", 1.50, "3-5 Days"),
        ("Express", 2.00, "Next Day")
    ]

    let paymentMethods: [(name: String, icon: String)] = [
        ("ABA Pay", "building.columns"),
        ("KHQR", "qrcode"),
        ("Visa / Mastercard", "creditcard"),
        ("Cash on Delivery", "banknote")
    ]

    let orderID = "PF-\(Int.random(in: 90000...99999))"

    var deliveryFee: Double {
        selectedDelivery == "Standard" ? 1.50 : 2.00
    }

    func total(cartPrice: Double) -> Double {
        cartPrice + deliveryFee
    }

    // ← updated to call API
    func confirmOrder(cart: CartModel, orders: OrdersModel, address: String, userId: Int) async {
        await MainActor.run {
            isLoading = true
            savedItems = cart.items
        }

        // build items array for API
        let itemsPayload = cart.items.map { item in
            [
                "plant_id":   item.plant.id.uuidString,
                "plant_name": item.plant.name,
                "price":      item.plant.price,
                "quantity":   item.quantity
            ] as [String: Any]
        }

        let body: [String: Any] = [
            "user_id":          userId,
            "order_number":     orderID,
            "total":            total(cartPrice: cart.totalPrice),
            "delivery_address": address,
            "items":            itemsPayload
        ]

        guard let url = URL(string: "\(APIService.shared.baseURL)/orders.php"),
              let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            await MainActor.run { isLoading = false }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let success = json["success"] as? Bool, success {

                // ← save to local OrdersModel too for instant UI update
                await orders.addOrder(
                    orderNumber: orderID,
                    items: cart.items,
                    total: total(cartPrice: cart.totalPrice),
                    deliveryAddress: address,
                    userId: userId
                )

                await MainActor.run {
                    cart.clearCart()
                    isLoading = false
                    orderPlaced = true
                }
            } else {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Failed to place order. Please try again."
                }
            }
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = "Network error: \(error.localizedDescription)"
            }
        }
    }
}
