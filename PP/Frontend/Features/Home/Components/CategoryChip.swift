//
//  CategoryChip.swift
//  PP
//
//  Created by Ly Kimheng on 12/8/26.
//

import SwiftUI

struct CategoryChip: View {
    let title: String
    var isSelected: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? Theme.onBrand : Theme.brand)
                .padding(.horizontal, Theme.Spacing.lg)
                .frame(height: 38)
                .background(isSelected ? Theme.brand : Theme.surface, in: Capsule())
                .overlay(
                    Capsule().strokeBorder(isSelected ? .clear : Theme.brand.opacity(0.35), lineWidth: 1)
                )
        }
        .buttonStyle(.pressable)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

#Preview {
    HStack {
        CategoryChip(title: "All", isSelected: true) {}
        CategoryChip(title: "Indoor") {}
    }
    .padding()
    .background(Theme.background)
}
