//
//  NotifactionView.swift
//  PP
//
//  Created by Ly Kimheng on 26/12/25.
//

import SwiftUI

struct NotificationsView: View {
    @EnvironmentObject var notifications: NotificationsModel
    @EnvironmentObject var user: UserModel

    var body: some View {
        Group {
            if notifications.notifications.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "bell.slash")
                        .font(.system(size: 60))
                        .foregroundColor(.gray.opacity(0.4))
                    Text("No notifications yet")
                        .font(.title3)
                        .foregroundColor(.gray)
                    Text("Updates about your orders will appear here")
                        .font(.caption)
                        .foregroundColor(.gray.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGray6))
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(notifications.notifications) { notification in
                            NotificationCard(notification: notification)
                                .onTapGesture {
                                    Task { await notifications.markAsRead(notification, userId: user.id) }
                                }
                        }
                    }
                    .padding(16)
                }
                .background(Color(.systemGray6))
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.light)
        .toolbar {
            if !notifications.notifications.isEmpty {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear All") {
                        Task { await notifications.deleteAll(userId: user.id) }
                    }
                    .foregroundColor(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255))
                }
            }
        }
        .onAppear {
            Task { await notifications.markAllAsRead(userId: user.id) }
        }
    }
}
#Preview {
    NavigationStack {
        NotificationsView()
            .environmentObject(NotificationsModel())
            .environmentObject(UserModel())
    }
}
