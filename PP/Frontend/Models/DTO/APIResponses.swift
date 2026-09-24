//
//  APIResponses.swift
//  PP
//
//  Created by Ly Kimheng on 12/8/26.
//

import Foundation

// MARK: - Generic

nonisolated struct StatusResponse: APIResponse {
    let success: Bool
    let message: String?
}

// MARK: - Auth

nonisolated struct UserResponse: APIResponse {
    let success: Bool
    let message: String?
    let user: UserDTO?
}

nonisolated struct UserDTO: Decodable {
    let id: Int
    let name: String
    let email: String
    let location: String
    let avatar: String?
}

nonisolated struct AvatarResponse: APIResponse {
    let success: Bool
    let message: String?
    let avatarURL: String?

    enum CodingKeys: String, CodingKey {
        case success, message
        case avatarURL = "avatar_url"
    }
}

// MARK: - Catalog

nonisolated struct PlantsResponse: APIResponse {
    let success: Bool
    let message: String?
    let plants: [PlantDTO]
}

nonisolated struct PlantDTO: Decodable {
    let id: Int
    let image: String
    let name: String
    let type: String
    let typePlant: String
    let price: Double
    let description: String
    let rating: Double
    let counting: Int
    let isPopular: Bool
    let discountPrice: Double?

    enum CodingKeys: String, CodingKey {
        case id, image, name, type, price, description, rating, counting
        case typePlant = "type_plant"
        case isPopular = "is_popular"
        case discountPrice = "discount_price"
    }

    var plant: PlantModel {
        PlantModel(
            id: id, image: image, name: name, type: type,
            typePlant: typePlant, price: price,
            description: description, rating: rating, counting: counting
        )
    }

    var specialOffer: PlantListing? {
        guard let discountPrice, discountPrice < price else { return nil }
        return PlantListing(plant, discountPrice: discountPrice)
    }
}

// MARK: - My plants

nonisolated struct MyPlantsResponse: APIResponse {
    let success: Bool
    let message: String?
    let plants: [MyPlantDTO]
}

nonisolated struct MyPlantDTO: Decodable {
    let id: Int
    let image: String
    let name: String
    let species: String
    let careLevel: String
    let nextWatering: String
    let sunlight: String

    enum CodingKeys: String, CodingKey {
        case id, image, name, species, sunlight
        case careLevel = "care_level"
        case nextWatering = "next_watering"
    }

    var myPlant: MyPlantModel {
        MyPlantModel(
            apiId: id,
            image: image,
            name: name,
            species: species,
            careLevel: MyPlantModel.CareLevel(rawValue: careLevel) ?? .easy,
            nextWatering: nextWatering,
            sunlight: sunlight
        )
    }
}

nonisolated struct AddMyPlantResponse: APIResponse {
    let success: Bool
    let message: String?
    let plantId: Int?

    enum CodingKeys: String, CodingKey {
        case success, message
        case plantId = "plant_id"
    }
}

// MARK: - Orders

nonisolated struct OrdersResponse: APIResponse {
    let success: Bool
    let message: String?
    let orders: [OrderDTO]
}

nonisolated struct OrderDTO: Decodable {
    let id: Int
    let orderNumber: String
    let status: String
    let total: Double
    let deliveryAddress: String
    let createdAt: String?
    let items: [OrderItemDTO]

    enum CodingKeys: String, CodingKey {
        case id, status, total, items
        case orderNumber = "order_number"
        case deliveryAddress = "delivery_address"
        case createdAt = "created_at"
    }

    var order: OrderModel {
        OrderModel(
            apiId: id,
            orderNumber: orderNumber,
            placedAt: OrderDateFormat.parse(createdAt),
            status: OrderModel.OrderStatus(apiValue: status),
            items: items.map(\.cartItem),
            total: total,
            deliveryAddress: deliveryAddress
        )
    }
}

nonisolated struct OrderItemDTO: Decodable {
    let plantId: Int
    let plantName: String
    let price: Double
    let quantity: Int
    let image: String?

    enum CodingKeys: String, CodingKey {
        case price, quantity, image
        case plantId = "plant_id"
        case plantName = "plant_name"
    }

    var cartItem: CartItem {
        CartItem(
            plant: PlantModel(
                id: plantId,
                image: image ?? "",
                name: plantName,
                type: "",
                typePlant: "",
                price: price,
                description: "",
                rating: 0,
                counting: 0
            ),
            quantity: quantity
        )
    }
}

nonisolated struct PlaceOrderResponse: APIResponse {
    let success: Bool
    let message: String?
    let orderId: Int?

    enum CodingKeys: String, CodingKey {
        case success, message
        case orderId = "order_id"
    }
}

// MARK: - Notifications

nonisolated struct NotificationsResponse: APIResponse {
    let success: Bool
    let message: String?
    let notifications: [NotificationDTO]
}

nonisolated struct NotificationDTO: Decodable {
    let id: Int
    let title: String
    let message: String
    let type: String
    let isRead: Int
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id, title, message, type
        case isRead = "is_read"
        case createdAt = "created_at"
    }

    var notification: NotificationModel {
        NotificationModel(
            apiId: id,
            title: title,
            message: message,
            date: OrderDateFormat.parse(createdAt),
            type: NotificationModel.NotificationType(apiValue: type),
            isRead: isRead == 1
        )
    }
}

// MARK: - Shared date parsing

nonisolated enum OrderDateFormat {
    private static let parser: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()

    static func parse(_ string: String?) -> Date {
        guard let string, let date = parser.date(from: string) else { return Date() }
        return date
    }
}
