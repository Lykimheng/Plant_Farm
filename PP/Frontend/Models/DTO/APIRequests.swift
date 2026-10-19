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
}

nonisolated struct ResetPasswordRequest: Encodable {
    let email: String
    let code: String
    let password: String
}

nonisolated struct UpdateProfileRequest: Encodable {
    let name: String
}

nonisolated struct UploadAvatarRequest: Encodable {
    let imageBase64: String

    enum CodingKeys: String, CodingKey {
        case imageBase64 = "image_base64"
    }
}

nonisolated struct AddMyPlantRequest: Encodable {
    let image: String
    let name: String
    let species: String
    let careLevel: String
    let nextWatering: String
    let sunlight: String

    enum CodingKeys: String, CodingKey {
        case image, name, species, sunlight
        case careLevel = "care_level"
        case nextWatering = "next_watering"
    }
}

nonisolated struct RemoveMyPlantRequest: Encodable {
    let plantId: Int

    enum CodingKeys: String, CodingKey {
        case plantId = "plant_id"
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

    let orderNumber: String
    let total: Double
    let deliveryAddress: String
    let deliveryOption: String
    let items: [Item]

    enum CodingKeys: String, CodingKey {
        case orderNumber = "order_number"
        case total
        case deliveryAddress = "delivery_address"
        case deliveryOption = "delivery_option"
        case items
    }
}

nonisolated struct NotificationUpdateRequest: Encodable {
    var notificationId: Int?

    enum CodingKeys: String, CodingKey {
        case notificationId = "notification_id"
    }
}

nonisolated struct SubmitReviewRequest: Encodable {
    let plantId: Int
    let rating: Int
    let body: String

    enum CodingKeys: String, CodingKey {
        case plantId = "plant_id"
        case rating, body
    }
}

nonisolated struct DeleteReviewRequest: Encodable {
    let plantId: Int
    let reviewId: Int

    enum CodingKeys: String, CodingKey {
        case plantId = "plant_id"
        case reviewId = "review_id"
    }
}
