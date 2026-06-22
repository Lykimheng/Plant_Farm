//
//  OrderResponse.swift
//  PP
//
//  Created by Ly Kimheng on 17/6/26.
//

import Foundation

// MARK: - Orders Response
struct OrdersResponse: Codable {
    let success: Bool
    let orders: [OrderAPIModel]
}

// MARK: - Single Order from API
struct OrderAPIModel: Codable {
    let id: Int
    let orderNumber: String
    let status: String
    let total: Double
    let deliveryAddress: String
    let createdAt: String
    let items: [OrderItemAPIModel]

    enum CodingKeys: String, CodingKey {
        case id
        case orderNumber = "order_number"
        case status
        case total
        case deliveryAddress = "delivery_address"
        case createdAt = "created_at"
        case items
    }

    // convert API model to OrderModel
    func toOrderModel() -> OrderModel {
        OrderModel(
            orderNumber: orderNumber,
            date: createdAt,
            status: OrderModel.OrderStatus(rawValue: status) ?? .pending,
            items: [],
            total: total,
            deliveryAddress: deliveryAddress
        )
    }
}

// MARK: - Order Item from API
struct OrderItemAPIModel: Codable {
    let id: Int
    let plantId: Int
    let plantName: String
    let price: Double
    let quantity: Int

    enum CodingKeys: String, CodingKey {
        case id
        case plantId = "plant_id"
        case plantName = "plant_name"
        case price
        case quantity
    }
}

// MARK: - Create Order Response
struct CreateOrderResponse: Codable {
    let success: Bool
    let message: String
    let orderId: Int?

    enum CodingKeys: String, CodingKey {
        case success
        case message
        case orderId = "order_id"
    }
}

// MARK: - Notifications Response
struct NotificationsResponse: Codable {
    let success: Bool
    let notifications: [NotificationAPIModel]
}

// MARK: - Single Notification from API
struct NotificationAPIModel: Codable {
    let id: Int
    let title: String
    let message: String
    let type: String
    let isRead: Int
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case message
        case type
        case isRead = "is_read"
        case createdAt = "created_at"
    }
}
