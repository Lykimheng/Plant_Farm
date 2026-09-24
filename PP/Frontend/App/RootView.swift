//
//  RootView.swift
//  PP
//
//  Created by Ly Kimheng on 7/8/26.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject private var user: UserStore
    @EnvironmentObject private var cart: CartStore
    @EnvironmentObject private var wishlist: WishlistStore
    @EnvironmentObject private var orders: OrdersStore
    @EnvironmentObject private var myPlants: MyPlantsStore
    @EnvironmentObject private var notifications: NotificationsStore
    @EnvironmentObject private var catalog: PlantsStore

    private enum Phase { case launching, ready }
    private static let minimumLaunchDuration: Duration = .seconds(1.3)
    @State private var phase: Phase = .launching
    @State private var hasEnteredApp = false

    var body: some View {
        ZStack {
            switch phase {
            case .launching:
                LaunchView()
                    .transition(.opacity)
                    .zIndex(1)

            case .ready:
                if hasEnteredApp || user.isLoggedIn {
                    MainTabView()
                        .transition(.opacity)
                } else {
                    StartScreen(onContinueAsGuest: { hasEnteredApp = true })
                        .transition(.opacity.combined(with: .scale(scale: 1.03)))
                }
            }
        }
        .animation(.easeInOut(duration: 0.45), value: phase)
        .animation(.easeInOut(duration: 0.3), value: user.isLoggedIn)
        .animation(.easeInOut(duration: 0.3), value: hasEnteredApp)
        .task { await launch() }
        .onChange(of: user.isLoggedIn) { wasLoggedIn, isLoggedIn in
            if wasLoggedIn && !isLoggedIn {
                signOutCleanup()
            }
        }
    }
    
    private func launch() async {
        Task { await catalog.loadIfNeeded() }
        try? await Task.sleep(for: Self.minimumLaunchDuration)
        phase = .ready
    }

    private func signOutCleanup() {
        cart.clear()
        wishlist.clear()
        orders.clearLocally()
        myPlants.clearLocally()
        notifications.clearLocally()
        hasEnteredApp = false
    }
}

struct LaunchView: View {
    private static let logoSize: CGFloat = 200

    @State private var settled = false
    @State private var ringExpanded = false
    @State private var showsProgress = false

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            Circle()
                .strokeBorder(Theme.brand.opacity(ringExpanded ? 0 : 0.35), lineWidth: 2)
                .frame(width: Self.logoSize * 0.7, height: Self.logoSize * 0.7)
                .scaleEffect(ringExpanded ? 2.2 : 1)
                .accessibilityHidden(true)

            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: Self.logoSize, height: Self.logoSize)
                .scaleEffect(settled ? 1 : 1.06)
                .accessibilityLabel("Plant Farm")
        }
        .overlay(alignment: .bottom) {
            ProgressView()
                .tint(Theme.brand)
                .opacity(showsProgress ? 1 : 0)
                .padding(.bottom, Theme.Spacing.xxl + Theme.Spacing.lg)
        }
        .onAppear(perform: animate)
    }

    private func animate() {
        withAnimation(.spring(response: 0.55, dampingFraction: 0.6)) {
            settled = true
        }
        withAnimation(.easeOut(duration: 1.1).delay(0.1)) {
            ringExpanded = true
        }
        withAnimation(.easeIn(duration: 0.3).delay(1.4)) {
            showsProgress = true
        }
    }
}
