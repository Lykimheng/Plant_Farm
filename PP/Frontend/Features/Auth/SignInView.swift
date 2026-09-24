//
//  SignInView.swift
//  PP
//
//  Created by Ly Kimheng on 26/12/25.
//

import SwiftUI

struct SignInView: View {
    var onSwitchToSignUp: (() -> Void)?

    @EnvironmentObject private var user: UserStore
    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var password = ""
    @State private var showForgotPassword = false
    @State private var validationMessage = ""

    private var canSubmit: Bool {
        !email.isBlank && !password.isEmpty && !user.isLoading
    }

    private var message: String {
        validationMessage.isEmpty ? user.errorMessage : validationMessage
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.xl) {
                VStack(spacing: Theme.Spacing.xs) {
                    Text("Welcome back")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Theme.textPrimary)
                    Text("Sign in to your Plant Farm account")
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.textSecondary)
                }
                .padding(.top, Theme.Spacing.xl)

                VStack(spacing: Theme.Spacing.md) {
                    AppTextField(
                        placeholder: "Email",
                        text: $email,
                        icon: Icons.mail,
                        kind: .email,
                        textContentType: .username
                    )

                    AppTextField(
                        placeholder: "Password",
                        text: $password,
                        icon: Icons.lock,
                        kind: .secure,
                        textContentType: .password,
                        submitLabel: .go
                    )

                    HStack {
                        Spacer()
                        Button("Forgot password?") { showForgotPassword = true }
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Theme.brand)
                    }
                }

                if !message.isEmpty {
                    Label(message, systemImage: "exclamationmark.triangle")
                        .font(.system(size: 12.5))
                        .foregroundStyle(Theme.danger)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button(action: submit) {
                    if user.isLoading {
                        ProgressView().tint(Theme.onBrand)
                    } else {
                        Text("Sign in")
                    }
                }
                .buttonStyle(.primary)
                .disabled(!canSubmit)

                if let onSwitchToSignUp {
                    HStack(spacing: 5) {
                        Text("Don't have an account?")
                            .foregroundStyle(Theme.textSecondary)
                        Button("Sign up", action: onSwitchToSignUp)
                            .fontWeight(.semibold)
                            .foregroundStyle(Theme.brand)
                    }
                    .font(.system(size: 14))
                }
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.bottom, Theme.Spacing.xxl)
            .readableWidth(Theme.Layout.compact)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Theme.background)
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView()
                .presentationDetents([.height(520), .large])
                .presentationDragIndicator(.visible)
        }
        .onDisappear { user.errorMessage = "" }
    }

    private func submit() {
        validationMessage = ""

        guard email.looksLikeEmail else {
            validationMessage = "Enter a valid email address."
            return
        }

        Task {
            if await user.login(email: email, password: password) {
                dismiss()
            }
        }
    }
}

#Preview {
    SignInView(onSwitchToSignUp: {})
        .environmentObject(UserStore())
}
