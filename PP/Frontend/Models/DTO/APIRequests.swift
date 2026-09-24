//
//  APIRequests.swift
//  PP
//
//  Created by Ly Kimheng on 12/8/26.
//

import Foundation

nonisolated struct RegisterRequest: Encodable {
    let name: String
    let email: String
    let password: String
    let location: String
}

nonisolated struct LoginRequest: Encodable {
    let email: String
    let password: String
}

nonisolated struct ForgotPasswordRequest: Encodable {
    let email: String
    let newPassword: String
}

nonisolated struct UpdateProfileRequest: Encodable {
    let userId: Int
    let name: String

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case name
    }
}

nonisolated struct UploadAvatarRequest: Encodable {
    let userId: Int
    let imageBase64: String

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case imageBase64 = "image_base64"
    }
}

nonisolated struct AddMyPlantRequest: Encodable {
    let userId: Int
    let image: String
    let name: String
    let species: String
    let careLevel: String
    let nextWatering: String
    let sunlight: String

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case image, name, species, sunlight
        case careLevel = "care_level"
        case nextWatering = "next_watering"
    }
}

nonisolated struct RemoveMyPlantRequest: Encodable {
    let plantId: Int
    let userId: Int

    enum CodingKeys: String, CodingKey {
        case plantId = "plant_id"
        case userId = "user_id"
    }
}

nonisolated struct PlaceOrderRequest: Encodable {
    struct Item: Encodable {
        let plantId: Int
        let plantName: String
        let price: Double
        let quantity: Int

        enum CodingKeys: String, CodingKey {
            case plantId = "plant_id"
            case plantName = "plant_name"
            case price, quantity
        }
    }

    let userId: Int
    let orderNumber: String
    let total: Double
    let deliveryAddress: String
    let items: [Item]

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case orderNumber = "order_number"
        case total
        case deliveryAddress = "delivery_address"
        case items
    }
}

nonisolated struct UpdateOrderStatusRequest: Encodable {
    let orderId: Int
    let status: String
    let userId: Int

    enum CodingKeys: String, CodingKey {
        case orderId = "order_id"
        case status
        case userId = "user_id"
    }
}

nonisolated struct NotificationUpdateRequest: Encodable {
    let userId: Int
    var notificationId: Int?

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case notificationId = "notification_id"
    }
}

nonisolated struct SubmitReviewRequest: Encodable {
    let plantId: Int
    let userId: Int
    let rating: Int
    let body: String

    enum CodingKeys: String, CodingKey {
        case plantId = "plant_id"
        case userId = "user_id"
        case rating, body
    }
}

nonisolated struct DeleteReviewRequest: Encodable {
    let plantId: Int
    let userId: Int
    let reviewId: Int

    enum CodingKeys: String, CodingKey {
        case plantId = "plant_id"
        case userId = "user_id"
        case reviewId = "review_id"
    }
}
