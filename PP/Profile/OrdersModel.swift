import Foundation
import Combine

final class OrdersModel: ObservableObject {
    @Published var orders: [OrderModel] = []
    
    init(orders: [OrderModel] = []) {
        self.orders = orders
    }
    
    // Example helper to add an order
    func add(_ order: OrderModel) {
        orders.append(order)
    }
}
