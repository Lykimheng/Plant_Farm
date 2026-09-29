//
//  LanguageManager.swift
//  PP
//
//  Created by Ly Kimheng on 24/9/26.
//

import SwiftUI
import Combine

enum AppLanguage: String, CaseIterable, Identifiable {
    case system, english, khmer

    var id: String { rawValue }
    var title: Text {
        switch self {
        case .system:  return Text("System")
        case .english: return Text(verbatim: "English")
        case .khmer:   return Text(verbatim: "ខ្មែរ")
        }
    }

    var locale: Locale {
        switch self {
        case .system:  return .autoupdatingCurrent
        case .english: return Locale(identifier: "en")
        case .khmer:   return Locale(identifier: "km")
        }
    }
}

@MainActor
final class LanguageManager: ObservableObject {
    private static let storageKey = "appLanguage"

    @Published var language: AppLanguage {
        didSet { UserDefaults.standard.set(language.rawValue, forKey: Self.storageKey) }
    }

    init() {
        let stored = UserDefaults.standard.string(forKey: Self.storageKey)
        language = stored.flatMap(AppLanguage.init(rawValue:)) ?? .system
    }

    var locale: Locale { language.locale }
}

nonisolated extension LocalizedStringResource {
    func string(in locale: Locale) -> String {
        var resource = self
        resource.locale = locale
        return String(localized: resource)
    }
}

nonisolated extension LocalizedStringResource {
    static func dynamic(_ text: String) -> LocalizedStringResource {
        LocalizedStringResource(String.LocalizationValue(text))
    }
}
