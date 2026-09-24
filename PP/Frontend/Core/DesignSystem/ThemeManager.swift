//
//  ThemeManager.swift
//  PP
//
//  Created by Ly Kimheng on 10/9/26.
//

import SwiftUI
import Combine

enum AppTheme: String, CaseIterable, Identifiable {
    case system, light, dark

    var id: String { rawValue }

    var label: String {
        switch self {
        case .system: return "System"
        case .light:  return "Light"
        case .dark:   return "Dark"
        }
    }

    var icon: String {
        switch self {
        case .system: return "iphone"
        case .light:  return "sun.max"
        case .dark:   return "moon"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }
}

@MainActor
final class ThemeManager: ObservableObject {
    private static let storageKey = "appTheme"

    @Published var theme: AppTheme {
        didSet { UserDefaults.standard.set(theme.rawValue, forKey: Self.storageKey) }
    }

    init() {
        let stored = UserDefaults.standard.string(forKey: Self.storageKey)
        theme = stored.flatMap(AppTheme.init(rawValue:)) ?? .system
    }

    var colorScheme: ColorScheme? { theme.colorScheme }
}
