//
//  OrdersStore.swift
//  PP
//
//  Created by Ly Kimheng on 12/8/26.
//

import SwiftUI
import Combine

@MainActor
final class OrdersStore: ObservableObject {
    @Published private(set) var orders: [OrderModel] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""

    private let client: APIClient
    private weak var notifications: NotificationsStore?

    init(client: APIClient = .shared) {
        self.client = client
    }

    func connect(notifications: NotificationsStore) {
        self.notifications = notifications
    }

    func order(withNumber number: String) -> OrderModel? {
        orders.first { $0.orderNumber == number }
    }

    func clearLocally() {
        orders.removeAll()
    }

    // MARK: - Server

    func load(userId: Int) async {
        guard userId != 0 else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let response: OrdersResponse = try await client.get(
                API.Path.orders,
                query: ["user_id": String(userId)]
            )
            orders = response.orders.map(\.order)
            errorMessage = ""
        } catch {
            errorMessage = error.userMessage
            AppLog.network("load orders", error)
        }
    }

    /// Places the order and returns the stored copy so the caller can navigate
    /// straight to it. Throws so the checkout screen can surface the reason.
    @discardableResult
    func placeOrder(
        userId: Int,
        orderNumber: String,
        items: [CartItem],
        total: Double,
        deliveryAddress: String
    ) async throws -> OrderModel {
        let response: PlaceOrderResponse = try await client.send(
            API.Path.orders,
            method: .post,
            body: PlaceOrderRequest(
                userId: userId,
                orderNumber: orderNumber,
                total: total,
                deliveryAddress: deliveryAddress,
                items: items.map {
                    .init(
                        plantId: $0.plant.id,
                        plantName: $0.plant.name,
                        price: $0.plant.price,
                        quantity: $0.quantity
                    )
                }
            )
        )

        let order = OrderModel(
            apiId: response.orderId ?? 0,
            orderNumber: orderNumber,
            placedAt: Date(),
            status: .pending,
            items: items,
            total: total,
            deliveryAddress: deliveryAddress
        )

        orders.insert(order, at: 0)
        notifications?.add(
            NotificationModel(
                title: "Order Placed",
                message: "Your order #\(orderNumber) is pending confirmation.",
                type: .orderPlaced
            )
        )
        return order
    }

    func cancel(_ order: OrderModel, userId: Int) async {
        guard let index = orders.firstIndex(where: { $0.id == order.id }) else { return }

        let previousStatus = orders[index].status
        orders[index].status = .cancelled

        do {
            let _: StatusResponse = try await client.send(
                API.Path.orders,
                method: .put,
                body: UpdateOrderStatusRequest(
                    orderId: order.apiId,
                    status: OrderModel.OrderStatus.cancelled.apiValue,
                    userId: userId
                )
            )
            notifications?.add(
                NotificationModel(
                    title: "Order Cancelled",
                    message: "You cancelled order #\(order.orderNumber).",
                    type: .orderCancelled
                )
            )
        } catch {
            orders[index].status = previousStatus
            errorMessage = error.userMessage
            AppLog.network("cancel order", error)
        }
    }
}
