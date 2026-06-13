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
    var notifications: NotificationsModel?    // ← link to notifications

    init(orders: [OrderModel] = []) {
        self.orders = orders
    }

    // ← create new order, starts as pending
    func addOrder(orderNumber: String, items: [CartItem], total: Double, deliveryAddress: String) {
        let newOrder = OrderModel(
            orderNumber: orderNumber,
            date: formattedDate(),
            status: .pending,
            items: items,
            total: total,
            deliveryAddress: deliveryAddress
        )
        orders.insert(newOrder, at: 0)

        // ← notify user order was placed
        notifications?.add(NotificationModel(
            title: "Order Placed",
            message: "Your order #\(orderNumber) is pending confirmation.",
            type: .orderPlaced
        ))
    }

    // ← user cancels their own pending order
    func cancelOrder(_ order: OrderModel) {
        guard let index = orders.firstIndex(where: { $0.id == order.id }) else { return }
        orders[index].status = .cancelled

        notifications?.add(NotificationModel(
            title: "Order Cancelled",
            message: "You cancelled order #\(order.orderNumber).",
            type: .orderCancelled
        ))
    }

    // ← simulate admin/shop confirming the order
    func confirmOrder(_ order: OrderModel) {
        guard let index = orders.firstIndex(where: { $0.id == order.id }) else { return }
        orders[index].status = .confirmed

        notifications?.add(NotificationModel(
            title: "Order Confirmed",
            message: "Your order #\(order.orderNumber) has been confirmed!",
            type: .orderConfirmed
        ))
    }

    // ← simulate shop rejecting the order
    func rejectOrder(_ order: OrderModel) {
        guard let index = orders.firstIndex(where: { $0.id == order.id }) else { return }
        orders[index].status = .rejected

        notifications?.add(NotificationModel(
            title: "Order Rejected",
            message: "Sorry, order #\(order.orderNumber) was rejected by the shop.",
            type: .orderRejected
        ))
    }

    func updateStatus(_ order: OrderModel, to status: OrderModel.OrderStatus) {
        guard let index = orders.firstIndex(where: { $0.id == order.id }) else { return }
        orders[index].status = status

        if status == .delivered {
            notifications?.add(NotificationModel(
                title: "Order Delivered",
                message: "Your order #\(order.orderNumber) has been delivered!",
                type: .orderDelivered
            ))
        }
    }

    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy - hh:mm a"
        return formatter.string(from: Date())
    }
}
