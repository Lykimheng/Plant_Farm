//
//  MainTabView.swift
//  PP
//
//  Created by Ly Kimheng on 7/8/26.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var cart: CartStore
    @EnvironmentObject private var catalog: PlantsStore
    @EnvironmentObject private var toast: ToastCenter
    @EnvironmentObject private var location: LocationManager
    @EnvironmentObject private var router: AppRouter

    private var tabSelection: Binding<AppTab> {
        Binding(
            get: { router.selectedTab },
            set: { newValue in
                if newValue == router.selectedTab && newValue == .home {
                    Task { await catalog.load() }
                }
                router.selectedTab = newValue
            }
        )
    }

    var body: some View {
        TabView(selection: tabSelection) {
            NavigationStack { HomeView() }
                .tabItem { Label(AppTab.home.title, systemImage: AppTab.home.icon) }
                .tag(AppTab.home)

            NavigationStack(path: $router.cartPath) {
                CartView()
                    .navigationDestination(for: CartRoute.self, destination: destination)
            }
            .tabItem { Label(AppTab.cart.title, systemImage: AppTab.cart.icon) }
            .badge(cart.totalCount)
            .tag(AppTab.cart)

            NavigationStack { ScanView() }
                .tabItem { Label(AppTab.scan.title, systemImage: AppTab.scan.icon) }
                .tag(AppTab.scan)

            NavigationStack { MyPlantsView() }
                .tabItem { Label(AppTab.myPlants.title, systemImage: AppTab.myPlants.icon) }
                .tag(AppTab.myPlants)

            NavigationStack { ProfileView() }
                .tabItem { Label(AppTab.profile.title, systemImage: AppTab.profile.icon) }
                .tag(AppTab.profile)
        }
        .tint(Theme.brand)
        .toast(center: toast)
        .task { location.requestPermissionIfNeeded() }
    }

    @ViewBuilder
    private func destination(for route: CartRoute) -> some View {
        switch route {
        case .checkout:
            CheckoutView()
        case .orderPlaced(let order):
            OrderSuccessView(order: order)
        case .orderDetail(let order):
            OrderDetailView(order: order)
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(CartStore())
        .environmentObject(UserStore())
        .environmentObject(WishlistStore())
        .environmentObject(OrdersStore())
        .environmentObject(NotificationsStore())
        .environmentObject(MyPlantsStore())
        .environmentObject(PlantsStore())
        .environmentObject(LocationManager())
        .environmentObject(ToastCenter())
        .environmentObject(ThemeManager())
        .environmentObject(AppRouter())
}
