//
//  Orders.swift
//  PP
//
//  Created by Ly Kimheng on 13/6/26.
//

import Foundation
import Combine
import SwiftUI

final class OrdersModel: ObservableObject {
    @Published var orders: [OrderModel] = []
    @Published var isLoading = false
    var notifications: NotificationsModel?

    // MARK: fetch from API
    func fetchOrders(userId: Int) async {
        await MainActor.run { isLoading = true }

        guard let url = URL(string: "\(APIService.shared.baseURL)/orders.php?user_id=\(userId)") else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(OrdersResponse.self, from: data)
            await MainActor.run {
                self.orders = response.orders.map { $0.toOrderModel() }
                self.isLoading = false
            }
        } catch {
            await MainActor.run { isLoading = false }
            print("Fetch orders error: \(error)")
        }
    }

    // MARK: save to API
    func addOrder(orderNumber: String, items: [CartItem], total: Double, deliveryAddress: String, userId: Int = 0) async {
        let body: [String: Any] = [
            "user_id": userId,
            "order_number": orderNumber,
            "total": total,
            "delivery_address": deliveryAddress,
            "items": items.map {[
                "plant_id": $0.plant.id.uuidString,
                "plant_name": $0.plant.name,
                "price": $0.plant.price,
                "quantity": $0.quantity
            ]}
        ]

        guard let url = URL(string: "\(APIService.shared.baseURL)/orders.php"),
              let jsonData = try? JSONSerialization.data(withJSONObject: body) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        do {
            let (_, _) = try await URLSession.shared.data(for: request)
            // add to local array immediately for instant UI update
            let newOrder = OrderModel(
                orderNumber: orderNumber,
                date: formattedDate(),
                status: .pending,
                items: items,
                total: total,
                deliveryAddress: deliveryAddress
            )
            await MainActor.run {
                orders.insert(newOrder, at: 0)
                notifications?.add(NotificationModel(
                    title: "Order Placed",
                    message: "Your order #\(orderNumber) is pending.",
                    type: .orderPlaced
                ))
            }
        } catch {
            print("Add order error: \(error)")
        }
    }
    func cancelOrder(_ order: OrderModel) async {
        guard let index = orders.firstIndex(where: { $0.id == order.id }) else { return }

        // ← update local state immediately
        await MainActor.run {
            orders[index].status = .cancelled
        }

        // ← update in API
        let body: [String: Any] = [
            "order_id": index + 1,
            "status": "cancelled",
            "user_id": 0           // ← pass real userId when available
        ]

        guard let url = URL(string: "\(APIService.shared.baseURL)/orders.php"),
              let jsonData = try? JSONSerialization.data(withJSONObject: body) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        do {
            let (_, _) = try await URLSession.shared.data(for: request)
            notifications?.add(NotificationModel(
                title: "Order Cancelled",
                message: "You cancelled order #\(order.orderNumber).",
                type: .orderCancelled
            ))
        } catch {
            print("Cancel order error: \(error)")
        }
    }

    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy - hh:mm a"
        return formatter.string(from: Date())
    }
}
