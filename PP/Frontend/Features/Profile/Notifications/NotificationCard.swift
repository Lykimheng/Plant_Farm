//
//  NotificationCard.swift
//  PP
//
//  Created by Ly Kimheng on 26/12/25.
//

import SwiftUI

struct NotificationCard: View {
    let notification: NotificationModel
    
    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            Image(systemName: notification.type.icon)
                .font(.system(size: 16))
                .foregroundStyle(notification.type.color)
                .frame(width: 42, height: 42)
                .background(notification.type.color.opacity(0.14), in: Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(LocalizedStringResource.dynamic(notification.title))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)

                Text(LocalizedStringResource.dynamic(notification.message))
                    .font(.system(size: 12.5))
                    .foregroundStyle(Theme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(notification.date, format: .relative(presentation: .named))
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.textTertiary)
            }

            Spacer(minLength: 0)

            if !notification.isRead {
                Circle()
                    .fill(Theme.brand)
                    .frame(width: 8, height: 8)
                    .accessibilityLabel("Unread")
            }
        }
        .padding(Theme.Spacing.md)
        .background(
            notification.isRead ? Theme.surface : Theme.brandTint,
            in: RoundedRectangle(cornerRadius: Theme.Radius.lg, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.lg, style: .continuous)
                .strokeBorder(Theme.separator, lineWidth: 0.7)
        )
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    VStack {
        NotificationCard(notification: NotificationModel(
            title: "Order Placed", message: "Your order #PF-98234 is pending confirmation.", type: .orderPlaced
        ))
        NotificationCard(notification: NotificationModel(
            title: "Delivered", message: "Order #PF-98230 arrived.", type: .orderDelivered, isRead: true
        ))
    }
    .padding()
    .background(Theme.background)
}
