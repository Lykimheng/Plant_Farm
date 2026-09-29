//
//  NotificationModel.swift
//  PP
//
//  Created by Ly Kimheng on 9/6/26.
//

import SwiftUI

nonisolated struct NotificationModel: Identifiable, Hashable {
    let id = UUID()
    var apiId: Int = 0
    let title: String
    let message: String
    var date: Date = Date()
    let type: NotificationType
    var isRead: Bool = false
    enum NotificationType: String {
        case orderPlaced
        case orderConfirmed
        case orderCancelled
        case orderRejected
        case orderDelivered

        init(apiValue: String) {
            self = NotificationType(rawValue: apiValue) ?? .orderPlaced
        }

        var icon: String {
            switch self {
            case .orderPlaced:    return "bag.fill"
            case .orderConfirmed: return "checkmark.circle.fill"
            case .orderCancelled: return "xmark.circle.fill"
            case .orderRejected:  return "exclamationmark.triangle.fill"
            case .orderDelivered: return "shippingbox.fill"
            }
        }

        var color: Color {
            switch self {
            case .orderPlaced:    return Theme.info
            case .orderConfirmed: return Theme.brand
            case .orderCancelled: return Theme.danger
            case .orderRejected:  return Theme.danger
            case .orderDelivered: return Theme.success
            }
        }
    }
}
