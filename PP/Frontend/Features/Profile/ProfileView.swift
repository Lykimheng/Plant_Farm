//
//  ProfileView.swift
//  PP
//
//  Created by Ly Kimheng on 26/12/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var user: UserStore
    @EnvironmentObject private var orders: OrdersStore
    @EnvironmentObject private var wishlist: WishlistStore
    @EnvironmentObject private var myPlants: MyPlantsStore
    @EnvironmentObject private var theme: ThemeManager

    @State private var showEditProfile = false
    @State private var showLogoutAlert = false

    var body: some View {
        Group {
            if user.isLoggedIn {
                content
            } else {
                SignInRequiredView(message: "Sign in to manage your profile, orders and saved plants.")
            }
        }
        .background(Theme.background)
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var content: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.xl) {
                header
                stats
                accountSection
                appSection
                logoutButton
                versionLabel
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.vertical, Theme.Spacing.lg)
            .readableWidth()
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileView()
                // .medium is under half an iPhone SE and cuts off the Save button
                .presentationDetents([.height(460), .large])
                .presentationDragIndicator(.visible)
        }
        .alert("Log out?", isPresented: $showLogoutAlert) {
            Button("Log out", role: .destructive) { user.logout() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You'll need to sign in again to see your orders and saved plants.")
        }
        .task { await orders.load(userId: user.id) }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: Theme.Spacing.md) {
            Button {
                showEditProfile = true
            } label: {
                ZStack(alignment: .bottomTrailing) {
                    UserAvatarView(avatarURL: user.avatarURL, size: 88)
                        .overlay(Circle().strokeBorder(Theme.brand, lineWidth: 2))

                    Image(systemName: Icons.pencil)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Theme.onBrand)
                        .frame(width: 26, height: 26)
                        .background(Theme.brand, in: Circle())
                        .overlay(Circle().strokeBorder(Theme.background, lineWidth: 2))
                }
            }
            .buttonStyle(.pressable)
            .accessibilityLabel("Edit profile photo and name")

            VStack(spacing: 3) {
                Text(user.name)
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)

                Text(user.email)
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.textSecondary)
            }

            Label("ITE Member", systemImage: Icons.verified)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Theme.brand)
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.vertical, 6)
                .background(Theme.brandTint, in: Capsule())
        }
        .padding(.top, Theme.Spacing.sm)
    }

    // MARK: - Stats

    private var stats: some View {
        HStack(spacing: Theme.Spacing.md) {
            StatCard(title: "My Plants", value: Text(myPlants.plants.count, format: .number))
            StatCard(title: "Orders", value: Text(orders.orders.count, format: .number))
            StatCard(title: "Care Level", value: Text("Lvl \(myPlants.careLevel)"))
        }
    }

    // MARK: - Sections

    private var accountSection: some View {
        SettingsGroup(title: "Account") {
            NavigationLink { MyOrdersView() } label: {
                SettingsRowLabel(icon: Icons.bag, title: "My Orders", detail: orders.orders.isEmpty ? nil : "\(orders.orders.count)")
            }
            SettingsDivider()
            NavigationLink { WishlistView() } label: {
                SettingsRowLabel(icon: Icons.favorite, title: "Wishlist", detail: wishlist.isEmpty ? nil : "\(wishlist.items.count)")
            }
            SettingsDivider()
            NavigationLink { PaymentMethodsView() } label: {
                SettingsRowLabel(icon: Icons.card, title: "Payment Methods")
            }
        }
    }

    private var appSection: some View {
        SettingsGroup(title: "App") {
            HStack(spacing: Theme.Spacing.md) {
                SettingsIcon(Icons.appearance)
                Text("Appearance")
                    .font(.system(size: 15))
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                Picker("Appearance", selection: $theme.theme) {
                    ForEach(AppTheme.allCases) { option in
                        Label(option.label, systemImage: option.icon).tag(option)
                    }
                }
                .pickerStyle(.menu)
                .tint(Theme.brand)
                // otherwise it shares the row with the Spacer and "System" wraps on small phones
                .fixedSize()
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.vertical, Theme.Spacing.sm)

            SettingsDivider()

            HStack(spacing: Theme.Spacing.md) {
                SettingsIcon(Icons.language)
                Text("Language")
                    .font(.system(size: 15))
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                LanguagePicker()
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.vertical, Theme.Spacing.sm)

            SettingsDivider()

            NavigationLink { HelpView() } label: {
                SettingsRowLabel(icon: Icons.help, title: "Help Center")
            }
        }
    }

    private var logoutButton: some View {
        Button {
            showLogoutAlert = true
        } label: {
            Label("Log out", systemImage: Icons.logout)
        }
        .buttonStyle(SecondaryButtonStyle(tint: Theme.danger))
    }

    private var versionLabel: some View {
        Text("Plant Farm \(Bundle.main.shortVersion) · Built for urban gardeners")
            .font(.system(size: 11.5))
            .foregroundStyle(Theme.textTertiary)
            .multilineTextAlignment(.center)
    }
}

// MARK: - Building blocks

struct StatCard: View {
    let title: LocalizedStringResource
    let value: Text

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            value
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Theme.brand)
                .contentTransition(.numericText())
            Text(title)
                .font(.system(size: 11.5))
                .foregroundStyle(Theme.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface(padding: Theme.Spacing.md)
        .accessibilityElement(children: .combine)
    }
}

struct SettingsGroup<Content: View>: View {
    let title: LocalizedStringResource
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text(title)
                .textCase(.uppercase)
                .font(.system(size: 11, weight: .semibold))
                .tracking(0.6)
                .foregroundStyle(Theme.textTertiary)
                .padding(.leading, Theme.Spacing.xs)

            VStack(spacing: 0) {
                content()
            }
            .cardBackground()
        }
    }
}

struct SettingsRowLabel: View {
    let icon: String
    let title: LocalizedStringResource
    var detail: String?

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            SettingsIcon(icon)
            Text(title)
                .font(.system(size: 15))
                .foregroundStyle(Theme.textPrimary)
            Spacer()
            if let detail {
                Text(detail)
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.textTertiary)
            }
            Image(systemName: Icons.forward)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Theme.textTertiary)
        }
        .padding(.horizontal, Theme.Spacing.lg)
        .frame(height: 54)
        .contentShape(Rectangle())
    }
}

struct SettingsIcon: View {
    let name: String

    init(_ name: String) { self.name = name }

    var body: some View {
        Image(systemName: name)
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(Theme.brand)
            .frame(width: 32, height: 32)
            .background(Theme.brandTint, in: RoundedRectangle(cornerRadius: Theme.Radius.sm, style: .continuous))
    }
}

struct SettingsDivider: View {
    var body: some View {
        Divider()
            .overlay(Theme.separator)
            .padding(.leading, 60)
    }
}

extension Bundle {
    var shortVersion: String {
        object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .environmentObject(UserStore())
            .environmentObject(WishlistStore())
            .environmentObject(OrdersStore())
            .environmentObject(MyPlantsStore())
            .environmentObject(ThemeManager())
            .environmentObject(CartStore())
            .environmentObject(LocationManager())
    }
}
