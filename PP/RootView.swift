//
//  RootView.swift
//  PP
//
//  Created by Ly Kimheng on 7/1/26.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var user: UserModel
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
        }
    }
}
