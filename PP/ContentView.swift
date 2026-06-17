//
//  ContentView.swift
//  PP
//
//  Created by Ly Kimheng on 24/12/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var cart: CartModel
    @EnvironmentObject var user: UserModel
    @EnvironmentObject var notifications: NotificationsModel
    var body: some View {
        TabView {
            NavigationStack{
                HomeView()
            }
            .tabItem {
                Label(Constants.homeString, systemImage: Constants.homeImageString)
            }
            NavigationStack {
                CartView()
                    .navigationTitle("My Cart")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label(Constants.cartString, systemImage: Constants.cartImageString)
            }
            .badge(cart.totalCount)
            
            NavigationStack{
                ScanView()
                    .navigationTitle("Identify plant")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label(Constants.scanString, systemImage: Constants.scanImageString)
            }
            
            NavigationStack{
                MyPlantView()
            }
            .tabItem {
                Label(Constants.myPlantString, systemImage: Constants.myPlantImageString)
            }
            
            NavigationStack{
                ProfileView()
            }
            .tabItem {
                Label(Constants.profileString, systemImage: Constants.profileImageString)
            }
                
        }
        .toast(isShowing: $cart.showToast, message: cart.toastMessage)
        .accentColor(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255))
        .onAppear {
            if user.isLoggedIn {
                Task {
                    await notifications.fetchNotifications(userId: user.id)
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(CartModel())
        .environmentObject(UserModel())
        .environmentObject(NotificationsModel())
}
