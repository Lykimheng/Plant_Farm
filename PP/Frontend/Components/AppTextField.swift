//
//  AppTextField.swift
//  PP
//
//  Created by Ly Kimheng on 12/8/26.
//

import SwiftUI
import UIKit

struct AppTextField: View {
    enum Kind {
        case plain
        case email
        case secure
        case number

        var isSecure: Bool { self == .secure }

        var maxLength: Int {
            switch self {
            case .plain:  return 100
            case .email:  return 150
            case .secure: return 128
            case .number: return 6
            }
        }
    }

    enum ReturnKey {
        case next, go, send, done

        var uiKitType: UIReturnKeyType {
            switch self {
            case .next: return .next
            case .go:   return .go
            case .send: return .send
            case .done: return .done
            }
        }
    }

    let placeholder: LocalizedStringResource
    @Binding var text: String
    var icon: String?
    var kind: Kind = .plain
    var textContentType: UITextContentType?
    var submitLabel: ReturnKey = .next
    var maxLength: Int?

    @Environment(\.locale) private var locale
    @State private var isRevealed = false
    @State private var isFocused = false

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundStyle(isFocused ? Theme.brand : Theme.textTertiary)
                    .frame(width: 18)
            }

            LimitedTextField(
                text: $text,
                isFocused: $isFocused,
                placeholder: placeholder.string(in: locale),
                isSecure: kind.isSecure && !isRevealed,
                maxLength: maxLength ?? kind.maxLength,
                keyboardType: kind == .email ? .emailAddress : kind == .number ? .numberPad : .default,
                contentType: textContentType,
                capitalization: kind == .plain ? .words : .none,
                returnKey: submitLabel.uiKitType
            )
            .accessibilityLabel(Text(placeholder))

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
}

private struct LimitedTextField: UIViewRepresentable {
    @Binding var text: String
    @Binding var isFocused: Bool
    let placeholder: String
    let isSecure: Bool
    let maxLength: Int
    let keyboardType: UIKeyboardType
    let contentType: UITextContentType?
    let capitalization: UITextAutocapitalizationType
    let returnKey: UIReturnKeyType

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> UITextField {
        let field = UITextField()
        field.delegate = context.coordinator
        field.font = .systemFont(ofSize: 15)
        field.textColor = UIColor(Theme.textPrimary)
        field.tintColor = UIColor(Theme.brand)
        field.autocorrectionType = .no
        field.spellCheckingType = .no
        field.setContentHuggingPriority(.defaultLow, for: .horizontal)
        field.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        field.addTarget(context.coordinator, action: #selector(Coordinator.textChanged(_:)), for: .editingChanged)
        return field
    }

    func updateUIView(_ field: UITextField, context: Context) {
        context.coordinator.parent = self

        if field.isSecureTextEntry != isSecure {
            field.isSecureTextEntry = isSecure
            let current = field.text
            field.text = nil
            field.text = current
        }
        if field.text != text { field.text = text }

        field.keyboardType = keyboardType
        field.textContentType = contentType
        field.autocapitalizationType = capitalization
        field.returnKeyType = returnKey
        field.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: UIColor.placeholderText, .font: UIFont.systemFont(ofSize: 15)]
        )
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        var parent: LimitedTextField

        init(_ parent: LimitedTextField) {
            self.parent = parent
        }

        func textField(
            _ textField: UITextField,
            shouldChangeCharactersIn range: NSRange,
            replacementString string: String
        ) -> Bool {
            let current = textField.text ?? ""
            guard let replaced = Range(range, in: current) else { return false }

            let room = parent.maxLength - (current.count - current[replaced].count)
            // only walks as far as the limit, however long the pasted text is
            if string.prefix(room + 1).count <= room { return true }

            // too long: insert just what fits, without letting UIKit see the rest
            let fitting = String(string.prefix(max(room, 0)))
            let updated = current.replacingCharacters(in: replaced, with: fitting)
            textField.text = updated
            let cursor = current.distance(from: current.startIndex, to: replaced.lowerBound) + fitting.count
            let offset = updated.prefix(cursor).utf16.count
            // UIKit resets the cursor after this returns, so place it on the next pass
            Task { @MainActor in
                if let position = textField.position(from: textField.beginningOfDocument, offset: offset) {
                    textField.selectedTextRange = textField.textRange(from: position, to: position)
                }
            }
            parent.text = updated
            return false
        }

        @objc func textChanged(_ textField: UITextField) {
            parent.text = textField.text ?? ""
        }

        func textFieldDidBeginEditing(_ textField: UITextField) {
            parent.isFocused = true
        }

        func textFieldDidEndEditing(_ textField: UITextField) {
            parent.isFocused = false
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
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
