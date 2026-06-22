//
//  DefaultAvatarView.swift
//  PP
//
//  Created by Ly Kimheng on 20/6/26.
//

import SwiftUI

// MARK: - Default_Profile
struct DefaultAvatarView: View {
    var size: CGFloat = 90

    var body: some View {
        Circle()
            .fill(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255).opacity(0.1))
            .frame(width: size, height: size)
            .overlay(
                Image(systemName: Constants.defaultUserIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size * 0.5, height: size * 0.5)
                    .foregroundColor(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255))
            )
    }
}

// MARK: - Update_User's profile or default profile
struct UserAvatarView: View {
    let avatarURL: String
    var size: CGFloat = 90

    var body: some View {
        if avatarURL.isEmpty {
            DefaultAvatarView(size: size)
        } else {
            RemoteImage(urlString: avatarURL)
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(Circle())
        }
    }
}
