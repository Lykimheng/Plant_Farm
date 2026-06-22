//
//  NotifactionCard.swift
//  PP
//
//  Created by Ly Kimheng on 13/6/26.
//

import SwiftUI

struct NotificationCard: View {
    let notification: NotificationModel

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(notification.type.color.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: notification.type.icon)
                    .foregroundColor(notification.type.color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(notification.title)
                    .font(.subheadline.bold())
                    .foregroundColor(.black)
                Text(notification.message)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(timeAgo(notification.date))
                    .font(.caption2)
                    .foregroundColor(.gray.opacity(0.7))
            }

            Spacer()

            if !notification.isRead {
                Circle()
                    .fill(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255))
                    .frame(width: 8, height: 8)
            }
        }
        .padding()
        .background(notification.isRead ? Color.white : Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255).opacity(0.05))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4)
    }

    func timeAgo(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
