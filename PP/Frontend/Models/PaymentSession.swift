//
//  PaymentSession.swift
//  PP
//
//  Created by Ly Kimheng on 3/11/26.
//

import Foundation

nonisolated struct PaymentSession: Equatable {
    let tranId: String
    let method: PaymentMethod
    let status: Status
    let amount: Double
    let expiresAt: Date
    let deeplink: URL?
    let qrString: String?
    let cardForm: CardForm?

    struct CardForm: Equatable {
        let html: String
        let baseURL: URL?
    }

    enum Status: String {
        case pending, approved, declined, cancelled, expired, refunded, failed

        init(apiValue: String) {
            self = Status(rawValue: apiValue) ?? .failed
        }
    }
}

nonisolated struct PaymentUpdate {
    let orderPaymentStatus: OrderModel.PaymentStatus
    let session: PaymentSession?

    var isPaid: Bool { orderPaymentStatus == .paid }
}
