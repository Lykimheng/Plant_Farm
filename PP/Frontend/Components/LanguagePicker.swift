//
//  LanguagePicker.swift
//  PP
//
//  Created by Ly Kimheng on 24/9/26.
//

import SwiftUI

struct LanguagePicker: View {
    @EnvironmentObject private var language: LanguageManager

    var body: some View {
        Picker("Language", selection: $language.language) {
            ForEach(AppLanguage.allCases) { option in
                option.title.tag(option)
            }
        }
        .pickerStyle(.menu)
        .tint(Theme.brand)
    }
}

struct LanguageMenuButton: View {
    @EnvironmentObject private var language: LanguageManager

    var body: some View {
        Menu {
            Picker("Language", selection: $language.language) {
                ForEach(AppLanguage.allCases) { option in
                    option.title.tag(option)
                }
            }
        } label: {
            Label {
                language.language.title
            } icon: {
                Image(systemName: Icons.language)
            }
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, Theme.Spacing.md)
            .frame(height: 34)
            .background(.ultraThinMaterial, in: Capsule())
        }
        .accessibilityLabel(Text("Language"))
    }
}

#Preview {
    VStack(spacing: 24) {
        LanguagePicker()
        LanguageMenuButton()
            .padding()
            .background(Theme.brand)
    }
    .environmentObject(LanguageManager())
}
