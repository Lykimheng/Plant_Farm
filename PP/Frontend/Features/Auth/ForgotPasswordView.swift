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
    @State private var code = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var validationMessage: LocalizedStringResource?
    @State private var codeSent = false
    @State private var didSucceed = false

    private static let minimumPasswordLength = 6
    private static let codeLength = 6
    private var message: LocalizedStringResource? {
        validationMessage ?? user.errorMessage
    }
    private var instructions: Text {
        codeSent
            ? Text("Enter the 6-digit code we emailed to \(email.trimmed) and choose a new password.")
            : Text("Enter your email and we'll send you a code to reset your password.")
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

                    instructions
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
                } else if !codeSent {
                    AppTextField(
                        placeholder: "Email",
                        text: $email,
                        icon: Icons.mail,
                        kind: .email,
                        textContentType: .username,
                        submitLabel: .send
                    )

                    InlineError(message: message)

                    Button(action: sendCode) {
                        if user.isLoading {
                            ProgressView().tint(Theme.onBrand)
                        } else {
                            Text("Send code")
                        }
                    }
                    .buttonStyle(.primary)
                    .disabled(email.isBlank || user.isLoading)
                } else {
                    VStack(spacing: Theme.Spacing.md) {
                        AppTextField(
                            placeholder: "6-digit code",
                            text: $code,
                            icon: "number",
                            kind: .number,
                            textContentType: .oneTimeCode
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
                    .disabled(code.isBlank || newPassword.isEmpty || user.isLoading)

                    Button("Send a new code") {
                        code = ""
                        validationMessage = nil
                        user.errorMessage = nil
                        codeSent = false
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Theme.brand)
                }
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.bottom, Theme.Spacing.xxl)
            .readableWidth(Theme.Layout.compact)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Theme.background)
        .onAppear { user.errorMessage = nil }
        .onDisappear { user.errorMessage = nil }
    }

    private func sendCode() {
        validationMessage = nil

        guard email.looksLikeEmail else {
            validationMessage = "Enter a valid email address."
            return
        }

        Task {
            if await user.requestPasswordReset(email: email) {
                withAnimation { codeSent = true }
            }
        }
    }

    private func submit() {
        validationMessage = nil

        guard code.trimmed.count == Self.codeLength, code.trimmed.allSatisfy(\.isNumber) else {
            validationMessage = "Enter the 6-digit code from the email."
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
            if await user.resetPassword(email: email, code: code, newPassword: newPassword) {
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
