//
//  AppTextField.swift
//  PP
//
//  Created by Ly Kimheng on 12/8/26.
//

import SwiftUI

struct AppTextField: View {
    enum Kind {
        case plain
        case email
        case secure

        var isSecure: Bool { self == .secure }
    }

    let placeholder: String
    @Binding var text: String
    var icon: String?
    var kind: Kind = .plain
    var textContentType: UITextContentType?
    var submitLabel: SubmitLabel = .next

    @State private var isRevealed = false
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundStyle(isFocused ? Theme.brand : Theme.textTertiary)
                    .frame(width: 18)
            }

            field
                .font(.system(size: 15))
                .foregroundStyle(Theme.textPrimary)
                .focused($isFocused)
                .submitLabel(submitLabel)
                .textContentType(textContentType)
                .autocorrectionDisabled()
                .textInputAutocapitalization(kind == .plain ? .words : .never)
                .keyboardType(kind == .email ? .emailAddress : .default)

            if kind.isSecure {
                Button {
                    isRevealed.toggle()
                } label: {
                    Image(systemName: isRevealed ? Icons.eyeOff : Icons.eye)
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.textTertiary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isRevealed ? "Hide password" : "Show password")
            }
        }
        .padding(.horizontal, Theme.Spacing.lg)
        .frame(height: 52)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous)
                .strokeBorder(isFocused ? Theme.brand : Theme.separator, lineWidth: isFocused ? 1.5 : 1)
        )
        .animation(.easeOut(duration: 0.15), value: isFocused)
    }

    @ViewBuilder
    private var field: some View {
        if kind.isSecure && !isRevealed {
            SecureField(placeholder, text: $text)
        } else {
            TextField(placeholder, text: $text)
        }
    }
}

#Preview {
    struct Demo: View {
        @State private var email = ""
        @State private var password = ""
        var body: some View {
            VStack(spacing: Theme.Spacing.lg) {
                AppTextField(placeholder: "Email", text: $email, icon: Icons.mail, kind: .email)
                AppTextField(placeholder: "Password", text: $password, icon: Icons.lock, kind: .secure)
            }
            .padding()
            .background(Theme.background)
        }
    }
    return Demo()
}
