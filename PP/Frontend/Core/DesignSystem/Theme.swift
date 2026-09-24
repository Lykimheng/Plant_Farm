//
//  Theme.swift
//  PP
//
//  Created by Ly Kimheng on 10/9/26.
//

import SwiftUI

// MARK: - Colour helpers

nonisolated extension Color {
    init(hex: UInt32, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }

    init(light: UInt32, dark: UInt32) {
        self.init(uiColor: UIColor { traits in
            UIColor(Color(hex: traits.userInterfaceStyle == .dark ? dark : light))
        })
    }
}

nonisolated extension Color {
    static let brand = Theme.brand
    static let brandAccent = Theme.brandAccent
}

// MARK: - Design tokens

nonisolated enum Theme {

    // Brand
    static let brand = Color(light: 0x17696E, dark: 0x1E8A90)
    static let brandAccent = Color(light: 0x20A9AC, dark: 0x2FC2C6)
    static let brandDeep = Color(light: 0x0F4C50, dark: 0x17696E)
    static let brandTint = Color(light: 0xE6F4F4, dark: 0x11262A)

    // Surfaces
    static let background = Color(light: 0xF5F7F7, dark: 0x0C1011)
    static let surface = Color(light: 0xFFFFFF, dark: 0x161B1C)
    static let surfaceAlt = Color(light: 0xF0F2F2, dark: 0x1F2627)

    // Text
    static let textPrimary = Color(light: 0x101817, dark: 0xF2F5F5)
    static let textSecondary = Color(light: 0x66716F, dark: 0x9AA5A4)
    static let textTertiary = Color(light: 0x98A2A1, dark: 0x6E7A79)
    static let onBrand = Color.white

    // Feedback
    static let separator = Color(light: 0xE4E9E8, dark: 0x2A3233)
    static let success = Color(light: 0x11875A, dark: 0x3FD397)
    static let warning = Color(light: 0xB4690E, dark: 0xF5B54A)
    static let danger = Color(light: 0xD03A3A, dark: 0xFF6B6B)
    static let info = Color(light: 0x2C6ECB, dark: 0x6BA6FF)
    static let star = Color(light: 0xF0A020, dark: 0xFFC257)

    static var brandGradient: LinearGradient {
        LinearGradient(colors: [brand, brandDeep], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    static var sectionWash: LinearGradient {
        LinearGradient(colors: [brandTint, background], startPoint: .top, endPoint: .bottom)
    }

    // MARK: - Metrics

    enum Radius {
        static let sm: CGFloat = 10
        static let md: CGFloat = 16
        static let lg: CGFloat = 22
        static let xl: CGFloat = 28
    }

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
    }

    enum Size {
        static let control: CGFloat = 52
        static let minimumTapTarget: CGFloat = 44
    }

    enum Layout {
        static let readable: CGFloat = 640
        static let compact: CGFloat = 480
        static let gridCellMin: CGFloat = 156
        static let gridCellMax: CGFloat = 230
    }
}

// MARK: - Surfaces

struct CardSurface: ViewModifier {
    var radius: CGFloat = Theme.Radius.lg
    var padding: CGFloat = Theme.Spacing.lg

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Theme.surface, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(Theme.separator, lineWidth: 0.7)
            )
    }
}

struct SoftShadow: ViewModifier {
    var radius: CGFloat = 14
    var y: CGFloat = 6

    func body(content: Content) -> some View {
        content.shadow(color: Color.black.opacity(0.07), radius: radius, x: 0, y: y)
    }
}

extension View {
    func cardSurface(radius: CGFloat = Theme.Radius.lg, padding: CGFloat = Theme.Spacing.lg) -> some View {
        modifier(CardSurface(radius: radius, padding: padding))
    }

    func cardBackground(radius: CGFloat = Theme.Radius.lg) -> some View {
        background(Theme.surface, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(Theme.separator, lineWidth: 0.7)
            )
    }

    func softShadow(radius: CGFloat = 14, y: CGFloat = 6) -> some View {
        modifier(SoftShadow(radius: radius, y: y))
    }
    
    func readableWidth(_ maxWidth: CGFloat = Theme.Layout.readable) -> some View {
        frame(maxWidth: maxWidth)
            .frame(maxWidth: .infinity)
    }
}

extension Array where Element == GridItem {
    static var plantGrid: [GridItem] {
        [GridItem(
            .adaptive(minimum: Theme.Layout.gridCellMin, maximum: Theme.Layout.gridCellMax),
            spacing: Theme.Spacing.lg
        )]
    }
}

// MARK: - Buttons

struct PressableStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    var fullWidth: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(Theme.onBrand)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .frame(height: Theme.Size.control)
            .padding(.horizontal, fullWidth ? 0 : Theme.Spacing.xl)
            .background(
                isEnabled ? Theme.brand : Theme.textTertiary,
                in: RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    var fullWidth: Bool = true
    var tint: Color = Theme.brand

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(tint)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .frame(height: Theme.Size.control)
            .padding(.horizontal, fullWidth ? 0 : Theme.Spacing.xl)
            .background(tint.opacity(0.1), in: RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous)
                    .strokeBorder(tint.opacity(0.35), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: PrimaryButtonStyle { PrimaryButtonStyle() }
}

extension ButtonStyle where Self == SecondaryButtonStyle {
    static var secondary: SecondaryButtonStyle { SecondaryButtonStyle() }
}

extension ButtonStyle where Self == PressableStyle {
    static var pressable: PressableStyle { PressableStyle() }
}
