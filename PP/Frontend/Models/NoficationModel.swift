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
    var apiId: Int = 0
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
    @Published var isLoading = false

    var unreadCount: Int {
        notifications.filter { !$0.isRead }.count
    }

    func add(_ notification: NotificationModel) {
        notifications.insert(notification, at: 0)
    }

    // local-only reset
    func clearAll() {
        notifications.removeAll()
    }

    // MARK: - Mark all as read (persisted)
    func markAllAsRead(userId: Int) async {
        await MainActor.run {
            for i in notifications.indices { notifications[i].isRead = true }
        }
        await sendUpdate(body: ["user_id": userId], method: "PUT")
    }

    // MARK: - Mark one as read (persisted)
    func markAsRead(_ notification: NotificationModel, userId: Int) async {
        await MainActor.run {
            if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
                notifications[index].isRead = true
            }
        }
        await sendUpdate(body: ["user_id": userId, "notification_id": notification.apiId], method: "PUT")
    }

    // MARK: - Delete all from the server (used by the "Clear All" button)
    func deleteAll(userId: Int) async {
        await MainActor.run { notifications.removeAll() }
        await sendUpdate(body: ["user_id": userId], method: "DELETE")
    }

    private func sendUpdate(body: [String: Any], method: String) async {
        guard let url = URL(string: "\(APIService.shared.baseURL)/notifactions.php"),
              let jsonData = try? JSONSerialization.data(withJSONObject: body) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        do {
            _ = try await URLSession.shared.data(for: request)
        } catch {
            print("Notification \(method) error: \(error)")
        }
    }

    // add API fetch
    func fetchNotifications(userId: Int) async {
        await MainActor.run { isLoading = true }

        guard let url = URL(string: "\(APIService.shared.baseURL)/notifactions.php?user_id=\(userId)") else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let notifArray = json["notifications"] as? [[String: Any]] {
                let fetched = notifArray.compactMap { dict -> NotificationModel? in
                    guard let apiId = dict["id"] as? Int,
                          let title = dict["title"] as? String,
                          let message = dict["message"] as? String,
                          let typeStr = dict["type"] as? String else { return nil }
                    return NotificationModel(
                        apiId: apiId,
                        title: title,
                        message: message,
                        type: notifType(from: typeStr),
                        isRead: (dict["is_read"] as? Int) == 1
                    )
                }
                await MainActor.run {
                    self.notifications = fetched
                    self.isLoading = false
                }
            }
        } catch {
            await MainActor.run { isLoading = false }
            print("Fetch notifications error: \(error)")
        }
    }

    // helper to convert string to enum
    private func notifType(from string: String) -> NotificationModel.NotificationType {
        switch string {
        case "orderConfirmed":  return .orderConfirmed
        case "orderCancelled":  return .orderCancelled
        case "orderRejected":   return .orderRejected
        case "orderDelivered":  return .orderDelivered
        default:                return .orderPlaced
        }
    }
}
