//
//  ContentView.swift
//  PP
//
//  Created by Ly Kimheng on 24/12/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var cart: CartModel
    @EnvironmentObject var toast: ToastCenter
    @EnvironmentObject var catalog: PlantsModel
    @State private var selectedTab = 0

    // MARK: - Tapping tabbar to refresh data
    private var tabSelection: Binding<Int> {
        Binding(
            get: { selectedTab },
            set: { newValue in
                if newValue == selectedTab && newValue == 0 {
                    Task { await catalog.fetchPlants() }
                }
                selectedTab = newValue
            }
        )
    }

    var body: some View {
        TabView(selection: tabSelection) {
            NavigationStack{
                HomeView()
            }
            .tabItem {
                Label(Constants.homeString, systemImage: Constants.homeImageString)
            }
            .tag(0)
            NavigationStack {
                CartView()
                    .navigationTitle("My Cart")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label(Constants.cartString, systemImage: Constants.cartImageString)
            }
            .badge(cart.totalCount)
            .tag(1)

            NavigationStack{
                ScanView()
                    .navigationTitle("Identify plant")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label(Constants.scanString, systemImage: Constants.scanImageString)
            }
            .tag(2)

            NavigationStack{
                MyPlantView()
            }
            .tabItem {
                Label(Constants.myPlantString, systemImage: Constants.myPlantImageString)
            }
            .tag(3)

            NavigationStack{
                ProfileView()
            }
            .tabItem {
                Label(Constants.profileString, systemImage: Constants.profileImageString)
            }
            .tag(4)

        }
        .toast(isShowing: $toast.isShowing, message: toast.message)
        .accentColor(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255))
    }
}

#Preview {
    ContentView()
        .environmentObject(CartModel())
        .environmentObject(UserModel())
        .environmentObject(NotificationsModel())
        .environmentObject(ToastCenter())
        .environmentObject(PlantsModel())
}
