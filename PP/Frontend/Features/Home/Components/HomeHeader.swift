//
//  HomeHeader.swift
//  PP
//
//  Created by Ly Kimheng on 12/8/26.
//

import SwiftUI

struct HomeHeader: View {
    @Binding var searchText: String
    var isCollapsed: Bool = false
    var scrollToTop: () -> Void = {}

    @EnvironmentObject private var user: UserStore
    @EnvironmentObject private var location: LocationManager
    @EnvironmentObject private var notifications: NotificationsStore
    @EnvironmentObject private var toast: ToastCenter

    @State private var showWishlist = false
    @State private var showNotifications = false
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            if isCollapsed {
                compactBar
            } else {
                expandedContent
            }
        }
        .padding(.horizontal, Theme.Spacing.lg)
        .padding(.top, Theme.Spacing.sm)
        .padding(.bottom, isCollapsed ? Theme.Spacing.sm : Theme.Spacing.lg)
        .readableWidth(Theme.Layout.wide)   // lines up with the content column below
        .background(Theme.brand.ignoresSafeArea(edges: .top))
        .animation(.easeInOut(duration: 0.25), value: isCollapsed)
        .sheet(isPresented: $showWishlist) {
            NavigationStack { WishlistView(isModal: true) }
                .toast(center: toast)
        }
        .sheet(isPresented: $showNotifications) {
            NavigationStack { NotificationsView() }
        }
        .task(id: user.id) {
            await notifications.load(userId: user.id)
        }
    }

    // MARK: - Collapsed

    private var compactBar: some View {
        HStack(spacing: Theme.Spacing.lg) {
            Label("Plant Farm", systemImage: Icons.myPlants)
                .labelStyle(.titleAndIcon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Theme.onBrand)

            Spacer()

            headerButton(Icons.search, label: "Search plants", action: scrollToTop)
            headerButton(Icons.favorite, label: "Wishlist") { showWishlist = true }
            notificationButton
        }
        .frame(height: 36)
    }

    // MARK: - Expanded

    private var expandedContent: some View {
        VStack(spacing: Theme.Spacing.lg) {
            HStack(spacing: Theme.Spacing.md) {
                UserAvatarView(avatarURL: user.avatarURL, size: 38)

                VStack(alignment: .leading, spacing: 2) {
                    Text(user.isLoggedIn ? "Hi, \(user.name)" : "Welcome")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Theme.onBrand)

                    locationText
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.onBrand.opacity(0.75))
                        .lineLimit(1)
                }

                Spacer(minLength: Theme.Spacing.sm)

                headerButton(Icons.favorite, label: "Wishlist") { showWishlist = true }
                notificationButton
            }

            searchField
        }
    }

    private var locationText: Text {
        let address = location.userAddress.isBlank ? user.location : location.userAddress
        return address.isBlank ? Text("Delivering nearby") : Text(address)
    }

    private var searchField: some View {
        HStack(spacing: Theme.Spacing.sm) {
            Image(systemName: Icons.search)
                .foregroundStyle(Theme.textTertiary)

            TextField("Search plants", text: $searchText)
                .focused($isSearchFocused)
                .foregroundStyle(Theme.textPrimary)
                .submitLabel(.search)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                    isSearchFocused = false
                } label: {
                    Image(systemName: Icons.closeCircle)
                        .foregroundStyle(Theme.textTertiary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, Theme.Spacing.md)
        .frame(height: 46)
        .background(Theme.surface, in: Capsule())
    }

    // MARK: - Buttons

    private func headerButton(_ icon: String, label: LocalizedStringResource, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Theme.onBrand)
                .frame(width: Theme.Size.minimumTapTarget, height: Theme.Size.minimumTapTarget)
                .contentShape(Rectangle())
        }
        .buttonStyle(.pressable)
        .accessibilityLabel(Text(label))
    }

    private var notificationButton: some View {
        Button {
            showNotifications = true
        } label: {
            Image(systemName: Icons.notification)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Theme.onBrand)
                .frame(width: Theme.Size.minimumTapTarget, height: Theme.Size.minimumTapTarget)
                .overlay(alignment: .topTrailing) {
                    if notifications.unreadCount > 0 {
                        Text(verbatim: notifications.unreadCount > 9 ? "9+" : "\(notifications.unreadCount)")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(Theme.onBrand)
                            .padding(.horizontal, 4)
                            .frame(minWidth: 15, minHeight: 15)
                            .background(Theme.danger, in: Capsule())
                            .offset(x: -4, y: 6)
                    }
                }
                .contentShape(Rectangle())
        }
        .buttonStyle(.pressable)
        .accessibilityLabel(
            notifications.unreadCount > 0
            ? "Notifications, \(notifications.unreadCount) unread"
            : "Notifications"
        )
    }
}
