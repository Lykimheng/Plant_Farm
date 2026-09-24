//
//  SignUpView.swift
//  PP
//
//  Created by Ly Kimheng on 25/12/25.
//

import SwiftUI

struct SignUpView: View {
    var onSwitchToSignIn: (() -> Void)?

    @EnvironmentObject private var user: UserStore
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var location = "Phnom Penh"
    @State private var validationMessage = ""

    private static let minimumPasswordLength = 6

    private var canSubmit: Bool {
        !name.isBlank && !email.isBlank && !password.isEmpty && !confirmPassword.isEmpty && !user.isLoading
    }

    private var message: String {
        validationMessage.isEmpty ? user.errorMessage : validationMessage
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.xl) {
                VStack(spacing: Theme.Spacing.xs) {
                    Text("Create your account")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Theme.textPrimary)
                    Text("Track your plants and keep your orders in one place")
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, Theme.Spacing.xl)

                VStack(spacing: Theme.Spacing.md) {
                    AppTextField(
                        placeholder: "Full name",
                        text: $name,
                        icon: Icons.user,
                        textContentType: .name
                    )

                    AppTextField(
                        placeholder: "Email",
                        text: $email,
                        icon: Icons.mail,
                        kind: .email,
                        textContentType: .username
                    )

                    AppTextField(
                        placeholder: "City",
                        text: $location,
                        icon: Icons.location,
                        textContentType: .addressCity
                    )

                    AppTextField(
                        placeholder: "Password",
                        text: $password,
                        icon: Icons.lock,
                        kind: .secure,
                        textContentType: .newPassword
                    )

                    AppTextField(
                        placeholder: "Confirm password",
                        text: $confirmPassword,
                        icon: Icons.lock,
                        kind: .secure,
                        textContentType: .newPassword,
                        submitLabel: .go
                    )

                    PasswordStrengthHint(password: password, minimumLength: Self.minimumPasswordLength)
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
                        Text("Create account")
                    }
                }
                .buttonStyle(.primary)
                .disabled(!canSubmit)

                if let onSwitchToSignIn {
                    HStack(spacing: 5) {
                        Text("Already have an account?")
                            .foregroundStyle(Theme.textSecondary)
                        Button("Sign in", action: onSwitchToSignIn)
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
        .onDisappear { user.errorMessage = "" }
    }

    private func submit() {
        validationMessage = ""

        guard email.looksLikeEmail else {
            validationMessage = "Enter a valid email address."
            return
        }
        guard password.count >= Self.minimumPasswordLength else {
            validationMessage = "Use at least \(Self.minimumPasswordLength) characters for your password."
            return
        }
        guard password == confirmPassword else {
            validationMessage = "The passwords don't match."
            return
        }

        Task {
            if await user.register(
                name: name,
                email: email,
                password: password,
                location: location.trimmed.isEmpty ? "Phnom Penh" : location.trimmed
            ) {
                dismiss()
            }
        }
    }
}

struct PasswordStrengthHint: View {
    let password: String
    var minimumLength: Int

    private var isLongEnough: Bool { password.count >= minimumLength }

    var body: some View {
        if !password.isEmpty {
            Label(
                isLongEnough ? "Password length looks good" : "At least \(minimumLength) characters",
                systemImage: isLongEnough ? "checkmark.circle.fill" : "circle"
            )
            .font(.system(size: 12))
            .foregroundStyle(isLongEnough ? Theme.success : Theme.textTertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    SignUpView(onSwitchToSignIn: {})
        .environmentObject(UserStore())
}
