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
    @StateObject private var favorite = FavoriteModel()
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(user)
                .environmentObject(cart)
                .environmentObject(location)
                .environmentObject(favorite)
                .onAppear{
                    location.requestPermission()
                }
        }
    }
}
