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
    @Published private(set) var errorMessage: LocalizedStringResource?

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

    // matched by server id: a reload gives every order a new `id`
    func latest(_ order: OrderModel) -> OrderModel {
        orders.first { $0.apiId == order.apiId && order.apiId != 0 } ?? order
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
            let response: OrdersResponse = try await client.get(API.Path.orders)
            orders = response.orders.map(\.order)
            errorMessage = nil
        } catch {
            errorMessage = error.userMessage
            AppLog.network("load orders", error)
        }
    }
    
    @discardableResult
    func placeOrder(
        orderNumber: String,
        items: [CartItem],
        total: Double,
        deliveryAddress: String,
        deliveryOption: String,
        paymentMethod: PaymentMethod
    ) async throws -> OrderModel {
        let response: PlaceOrderResponse = try await client.send(
            API.Path.orders,
            method: .post,
            body: PlaceOrderRequest(
                orderNumber: orderNumber,
                total: total,
                deliveryAddress: deliveryAddress,
                deliveryOption: deliveryOption,
                paymentMethod: paymentMethod.id,
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
            total: response.total ?? total,
            deliveryAddress: deliveryAddress,
            paymentMethod: paymentMethod
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

    // MARK: - Payment

    func startPayment(for order: OrderModel, method: PaymentMethod) async throws -> PaymentUpdate {
        let response: PaymentResponse = try await client.send(
            API.Path.startPayment(order.apiId),
            method: .post,
            body: StartPaymentRequest(method: method.id)
        )
        return apply(response.update, to: order)
    }

    func refreshPayment(for order: OrderModel) async throws -> PaymentUpdate {
        let response: PaymentResponse = try await client.get(API.Path.payment(order.apiId))
        return apply(response.update, to: order)
    }

    func cancelPayment(for order: OrderModel) async throws -> PaymentUpdate {
        let response: PaymentResponse = try await client.send(API.Path.cancelPayment(order.apiId), method: .post)
        return apply(response.update, to: order)
    }

    private func apply(_ update: PaymentUpdate, to order: OrderModel) -> PaymentUpdate {
        guard let index = orders.firstIndex(where: { $0.apiId == order.apiId }) else { return update }

        let wasPaid = orders[index].isPaid
        orders[index].paymentStatus = update.orderPaymentStatus
        if let method = update.session?.method {
            orders[index].paymentMethod = method
        }

        if !wasPaid && update.isPaid {
            notifications?.add(
                NotificationModel(
                    title: "Payment Received",
                    message: "We received your payment for order #\(order.orderNumber).",
                    type: .paymentReceived
                )
            )
        }
        return update
    }

    func cancel(_ order: OrderModel) async {
        guard let index = orders.firstIndex(where: { $0.id == order.id }) else { return }

        let previousStatus = orders[index].status
        orders[index].status = .cancelled
        errorMessage = nil

        do {
            let _: StatusResponse = try await client.send(API.Path.cancelOrder(order.apiId), method: .post)
            notifications?.add(
                NotificationModel(
                    title: "Order Cancelled",
                    message: "You cancelled order #\(order.orderNumber).",
                    type: .orderCancelled
                )
            )
        } catch {
            if let index = orders.firstIndex(where: { $0.id == order.id }) {
                orders[index].status = previousStatus
            }
            errorMessage = error.userMessage
            AppLog.network("cancel order", error)
        }
    }
}
