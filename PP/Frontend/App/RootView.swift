//
//  RootView.swift
//  PP
//
//  Created by Ly Kimheng on 7/1/26.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var user: UserModel
    @EnvironmentObject var cart: CartModel
    @EnvironmentObject var wishlist: WishlistModel
    @EnvironmentObject var orders: OrdersModel
    @EnvironmentObject var myPlants: MyPlantsModel
    @EnvironmentObject var notifications: NotificationsModel
    @State private var isLoggedIn = false

    var body: some View {
        Group {
            if isLoggedIn {
                ContentView()
            } else {
                StartScreen(isLoggedIn: $isLoggedIn)
            }
        }
        .onChange(of: user.isLoggedIn) { oldValue, newValue in
            isLoggedIn = newValue
            // logging out — wipe per-account data 
            if oldValue && !newValue {
                cart.clearCart()
                wishlist.clearAll()
                orders.orders.removeAll()
                myPlants.plants.removeAll()
                notifications.clearAll()
            }
        }
    }
}
