//
//  PPApp.swift
//  PP
//
//  Created by Ly Kimheng on 24/12/25.
//

import SwiftUI

@main
struct PPApp: App {
    @StateObject private var user = UserStore()
    @StateObject private var cart = CartStore()
    @StateObject private var wishlist = WishlistStore()
    @StateObject private var orders = OrdersStore()
    @StateObject private var notifications = NotificationsStore()
    @StateObject private var myPlants = MyPlantsStore()
    @StateObject private var catalog = PlantsStore()
    @StateObject private var location = LocationManager()
    @StateObject private var toast = ToastCenter()
    @StateObject private var theme = ThemeManager()
    @StateObject private var router = AppRouter()
    @StateObject private var language = LanguageManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(user)
                .environmentObject(cart)
                .environmentObject(wishlist)
                .environmentObject(orders)
                .environmentObject(notifications)
                .environmentObject(myPlants)
                .environmentObject(catalog)
                .environmentObject(location)
                .environmentObject(toast)
                .environmentObject(theme)
                .environmentObject(router)
                .environmentObject(language)
                .environment(\.locale, language.locale)
                .preferredColorScheme(theme.colorScheme)
                .task {
                    cart.connect(toastCenter: toast)
                    orders.connect(notifications: notifications)
                }
        }
    }
}
