//
//  EmptyStateView.swift
//  PP
//
//  Created by Ly Kimheng on 7/8/26.
//

import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    var message: String?
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 46, weight: .light))
                .foregroundStyle(Theme.textTertiary)

            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Theme.textPrimary)

            if let message {
                Text(message)
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(SecondaryButtonStyle(fullWidth: false))
                    .padding(.top, Theme.Spacing.xs)
            }
        }
        .padding(.horizontal, Theme.Spacing.xxl)
        .padding(.vertical, Theme.Spacing.xxl)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }
}

struct LoadingStateView: View {
    var message: String = "Loading…"

    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            ProgressView()
            Text(message)
                .font(.system(size: 13))
                .foregroundStyle(Theme.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Spacing.xxl)
    }
}

struct SkeletonList: View {
    var count: Int = 3
    var height: CGFloat = 90

    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            ForEach(0..<count, id: \.self) { _ in
                RoundedRectangle(cornerRadius: Theme.Radius.lg, style: .continuous)
                    .fill(Theme.surfaceAlt)
                    .frame(height: height)
            }
        }
        .accessibilityHidden(true)
    }
}

#Preview {
    VStack {
        EmptyStateView(
            icon: Icons.cart,
            title: "Your cart is empty",
            message: "Browse the shop and add a plant to get started.",
            actionTitle: "Browse plants",
            action: {}
        )
        LoadingStateView()
    }
    .background(Theme.background)
}
