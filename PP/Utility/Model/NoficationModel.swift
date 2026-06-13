//
//  NoficationModel.swift
//  PP
//
//  Created by Ly Kimheng on 13/6/26.
//

import SwiftUI
import Combine

struct NotificationModel: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let date: Date = Date()
    let type: NotificationType
    var isRead: Bool = false

    enum NotificationType {
        case orderPlaced
        case orderConfirmed
        case orderCancelled
        case orderRejected
        case orderDelivered

        var icon: String {
            switch self {
            case .orderPlaced:    return "bag.fill"
            case .orderConfirmed: return "checkmark.circle.fill"
            case .orderCancelled: return "xmark.circle.fill"
            case .orderRejected:  return "exclamationmark.triangle.fill"
            case .orderDelivered: return "truck.box.fill"
            }
        }

        var color: Color {
            switch self {
            case .orderPlaced:    return .blue
            case .orderConfirmed: return Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255)
            case .orderCancelled: return .red
            case .orderRejected:  return .red
            case .orderDelivered: return .green
            }
        }
    }
}

class NotificationsModel: ObservableObject {
    @Published var notifications: [NotificationModel] = []

    var unreadCount: Int {
        notifications.filter { !$0.isRead }.count
    }

    func add(_ notification: NotificationModel) {
        notifications.insert(notification, at: 0)
    }

    func markAllAsRead() {
        for i in notifications.indices {
            notifications[i].isRead = true
        }
    }

    func markAsRead(_ notification: NotificationModel) {
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index].isRead = true
        }
    }

    func clearAll() {
        notifications.removeAll()
    }
}
