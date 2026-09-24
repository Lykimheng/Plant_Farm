//
//  AvatarView.swift
//  PP
//
//  Created by Ly Kimheng on 7/8/26.
//


import SwiftUI

struct UserAvatarView: View {
    let avatarURL: String
    var size: CGFloat = 90

    var body: some View {
        Group {
            if avatarURL.isBlank {
                Circle()
                    .fill(Theme.brandTint)
                    .overlay(
                        Image(systemName: Icons.profile)
                            .font(.system(size: size * 0.42, weight: .medium))
                            .foregroundStyle(Theme.brand)
                    )
            } else {
                RemoteImage(urlString: avatarURL, placeholderSymbol: Icons.profile)
                    .scaledToFill()
                    .clipShape(Circle())
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

#Preview {
    HStack(spacing: 20) {
        UserAvatarView(avatarURL: "", size: 64)
        UserAvatarView(avatarURL: "", size: 40)
    }
    .padding()
    .background(Theme.background)
}
