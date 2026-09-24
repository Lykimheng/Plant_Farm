//
//  NotificationsStore.swift
//  PP
//
//  Created by Ly Kimheng on 12/8/26.
//

import SwiftUI
import Combine

@MainActor
final class NotificationsStore: ObservableObject {
    @Published private(set) var notifications: [NotificationModel] = []
    @Published private(set) var isLoading = false

    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    var unreadCount: Int { notifications.count { !$0.isRead } }

    var isEmpty: Bool { notifications.isEmpty }

    func add(_ notification: NotificationModel) {
        notifications.insert(notification, at: 0)
    }

    func clearLocally() {
        notifications.removeAll()
    }

    // MARK: - Server

    func load(userId: Int) async {
        guard userId != 0 else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let response: NotificationsResponse = try await client.get(
                API.Path.notifications,
                query: ["user_id": String(userId)]
            )
            notifications = response.notifications.map(\.notification)
        } catch {
            AppLog.network("load notifications", error)
        }
    }

    func markAllAsRead(userId: Int) async {
        guard unreadCount > 0 else { return }
        for index in notifications.indices { notifications[index].isRead = true }
        await update(.put, NotificationUpdateRequest(userId: userId))
    }

    func markAsRead(_ notification: NotificationModel, userId: Int) async {
        guard let index = notifications.firstIndex(where: { $0.id == notification.id }),
              !notifications[index].isRead else { return }

        notifications[index].isRead = true
        await update(.put, NotificationUpdateRequest(userId: userId, notificationId: notification.apiId))
    }

    func deleteAll(userId: Int) async {
        let previous = notifications
        notifications.removeAll()

        do {
            let _: StatusResponse = try await client.send(
                API.Path.notifications,
                method: .delete,
                body: NotificationUpdateRequest(userId: userId)
            )
        } catch {
            // put them back rather than silently losing the list
            notifications = previous
            AppLog.network("delete notifications", error)
        }
    }

    private func update(_ method: HTTPMethod, _ body: NotificationUpdateRequest) async {
        do {
            let _: StatusResponse = try await client.send(API.Path.notifications, method: method, body: body)
        } catch {
            AppLog.network("update notifications", error)
        }
    }
}
