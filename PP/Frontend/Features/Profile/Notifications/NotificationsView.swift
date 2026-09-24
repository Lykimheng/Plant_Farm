//
//  NotificationsView.swift
//  PP
//
//  Created by Ly Kimheng on 26/12/25.
//

import SwiftUI

struct NotificationsView: View {
    @EnvironmentObject private var notifications: NotificationsStore
    @EnvironmentObject private var user: UserStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Group {
            if notifications.isLoading && notifications.isEmpty {
                SkeletonList(count: 4, height: 78)
                    .padding(Theme.Spacing.lg)
            } else if notifications.isEmpty {
                EmptyStateView(
                    icon: Icons.notificationOff,
                    title: "No notifications yet",
                    message: "Updates about your orders will show up here."
                )
                .frame(maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: Theme.Spacing.md) {
                        ForEach(notifications.notifications) { notification in
                            NotificationCard(notification: notification)
                                .onTapGesture {
                                    Task { await notifications.markAsRead(notification, userId: user.id) }
                                }
                        }
                    }
                    .padding(Theme.Spacing.lg)
                    .readableWidth()
                }
                .refreshable { await notifications.load(userId: user.id) }
            }
        }
        .background(Theme.background)
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Done") { dismiss() }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("Mark all as read", systemImage: Icons.checkmark) {
                        Task { await notifications.markAllAsRead(userId: user.id) }
                    }
                    .disabled(notifications.unreadCount == 0)

                    Button("Clear all", systemImage: Icons.trash, role: .destructive) {
                        Task { await notifications.deleteAll(userId: user.id) }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                .disabled(notifications.isEmpty)
            }
        }
        .task { await notifications.load(userId: user.id) }
    }
}

#Preview {
    NavigationStack {
        NotificationsView()
            .environmentObject(NotificationsStore())
            .environmentObject(UserStore())
    }
}
