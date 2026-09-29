//
//  SignInRequiredView.swift
//  PP
//
//  Created by Ly Kimheng on 20/6/26.
//

import SwiftUI

struct SignInRequiredView: View {
    let message: LocalizedStringResource
    @State private var showSignIn = false
    @State private var showSignUp = false

    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Image(systemName: Icons.userCircle)
                .font(.system(size: 46, weight: .light))
                .foregroundStyle(Theme.textTertiary)

            Text("Sign in required")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Theme.textPrimary)

            Text(message)
                .font(.system(size: 13.5))
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: Theme.Spacing.md) {
                Button("Sign in") { showSignIn = true }
                    .buttonStyle(.primary)

                Button("Create an account") { showSignUp = true }
                    .buttonStyle(.secondary)
            }
            .padding(.top, Theme.Spacing.xs)
        }
        .padding(.horizontal, Theme.Spacing.xl)
        .frame(maxWidth: 420)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $showSignIn) {
            SignInView()
                .presentationDetents([.height(520), .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showSignUp) {
            SignUpView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    SignInRequiredView(message: "Sign in to manage your profile, orders and saved plants.")
        .environmentObject(UserStore())
}
