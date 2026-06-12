import Foundation
import Combine
import SwiftUI

final class OrdersModel: ObservableObject {
    @Published var orders: [OrderModel] = []

    init(orders: [OrderModel] = []) {
        self.orders = orders
    }

    // ← keep existing add
    func add(_ order: OrderModel) {
        orders.insert(order, at: 0)    // ← newest first
    }

    // ← add this new helper for checkout
    func addOrder(orderNumber: String, items: [CartItem], total: Double, deliveryAddress: String) {
        let newOrder = OrderModel(
            orderNumber: orderNumber,
            date: formattedDate(),
            status: .placed,
            items: items,
            total: total,
            deliveryAddress: deliveryAddress
        )
        orders.insert(newOrder, at: 0)    // ← newest first
    }

    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy - hh:mm a"
        return formatter.string(from: Date())
    }
}
