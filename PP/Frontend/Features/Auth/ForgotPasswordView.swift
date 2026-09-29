//
//  ForgotPasswordView.swift
//  PP
//
//  Created by Ly Kimheng on 27/12/25.
//

import SwiftUI

struct ForgotPasswordView: View {
    @EnvironmentObject private var user: UserStore
    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var validationMessage: LocalizedStringResource?
    @State private var didSucceed = false

    private static let minimumPasswordLength = 6
    private var message: LocalizedStringResource? {
        validationMessage ?? user.errorMessage
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.xl) {
                VStack(spacing: Theme.Spacing.sm) {
                    Image(systemName: "lock.rotation")
                        .font(.system(size: 40, weight: .light))
                        .foregroundStyle(Theme.brand)

                    Text("Reset your password")
                        .font(.system(size: 21, weight: .bold))
                        .foregroundStyle(Theme.textPrimary)

                    Text("Enter your email and choose a new password.")
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, Theme.Spacing.xl)

                if didSucceed {
                    Label("Password updated. You can sign in with it now.", systemImage: "checkmark.circle.fill")
                        .font(.system(size: 13.5, weight: .medium))
                        .foregroundStyle(Theme.success)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .cardSurface(padding: Theme.Spacing.md)
                } else {
                    VStack(spacing: Theme.Spacing.md) {
                        AppTextField(
                            placeholder: "Email",
                            text: $email,
                            icon: Icons.mail,
                            kind: .email,
                            textContentType: .username
                        )
                        AppTextField(
                            placeholder: "New password",
                            text: $newPassword,
                            icon: Icons.lock,
                            kind: .secure,
                            textContentType: .newPassword
                        )
                        AppTextField(
                            placeholder: "Confirm new password",
                            text: $confirmPassword,
                            icon: Icons.lock,
                            kind: .secure,
                            textContentType: .newPassword,
                            submitLabel: .go
                        )
                    }

                    InlineError(message: message)

                    Button(action: submit) {
                        if user.isLoading {
                            ProgressView().tint(Theme.onBrand)
                        } else {
                            Text("Reset password")
                        }
                    }
                    .buttonStyle(.primary)
                    .disabled(email.isBlank || newPassword.isEmpty || user.isLoading)
                }
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.bottom, Theme.Spacing.xxl)
            .readableWidth(Theme.Layout.compact)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Theme.background)
        .onDisappear { user.errorMessage = nil }
    }

    private func submit() {
        validationMessage = nil

        guard email.looksLikeEmail else {
            validationMessage = "Enter a valid email address."
            return
        }
        guard newPassword.count >= Self.minimumPasswordLength else {
            validationMessage = "Use at least \(Self.minimumPasswordLength) characters."
            return
        }
        guard newPassword == confirmPassword else {
            validationMessage = "The passwords don't match."
            return
        }

        Task {
            if await user.resetPassword(email: email, newPassword: newPassword) {
                withAnimation { didSucceed = true }
                try? await Task.sleep(for: .seconds(1.4))
                dismiss()
            }
        }
    }
}

#Preview {
    ForgotPasswordView()
        .environmentObject(UserStore())
}
