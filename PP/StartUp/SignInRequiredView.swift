//
//  SignInRequiredView.swift
//  PP
//
//  Created by Ly Kimheng on 20/6/26.
//

import SwiftUI

// MARK: - Pop up for Guest
struct SignInRequiredView: View {
    let message: String
    @State private var showSignIn = false
    @State private var dummyIsLoggedIn = false

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: Constants.notificationIcon)
                .font(.system(size: 50))
                .foregroundColor(.gray)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Button {
                showSignIn = true
            } label: {
                Text("Sign In")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255))
                    .cornerRadius(10)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
        .padding(.bottom, 60)
        .sheet(isPresented: $showSignIn) {
            SigninView(isLoggedIn: $dummyIsLoggedIn, showLogin: $showSignIn)
                .presentationDetents([.fraction(0.7)])
                .presentationDragIndicator(.visible)
        }
    }
}
