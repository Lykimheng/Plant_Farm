//
//  PPApp.swift
//  PP
//
//  Created by Ly Kimheng on 24/12/25.
//

import SwiftUI

@main
struct PPApp: App {
    @StateObject private var user = UserModel()
    @StateObject private var cart = CartModel()
    @StateObject private var location = LocationManager()
    @StateObject private var wishlist = WishlistModel()
    @StateObject private var orders = OrdersModel()
    @StateObject private var notifactions = NotificationsModel()
    @StateObject private var myPlants = MyPlantsModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(user)
                .environmentObject(cart)
                .environmentObject(location)
                .environmentObject(wishlist)
                .environmentObject(orders)
                .environmentObject(notifactions)
                .environmentObject(myPlants)
                .onAppear{
                    location.requestPermission()
                    orders.notifications = notifactions
                }
        }
    }
}

