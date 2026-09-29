//
//  QuantityStepper.swift
//  PP
//
//  Created by Ly Kimheng on 7/8/26.
//

import SwiftUI

struct QuantityStepper: View {
    let quantity: Int
    var minimum: Int = 1
    var maximum: Int = 99
    var compact: Bool = false
    var removesAtMinimum: Bool = true
    let onDecrement: () -> Void
    let onIncrement: () -> Void

    private var side: CGFloat { compact ? 28 : 34 }

    private var decrementIcon: String {
        quantity <= minimum && removesAtMinimum ? "trash" : "minus"
    }

    var body: some View {
        HStack(spacing: 0) {
            button(
                icon: decrementIcon,
                enabled: removesAtMinimum || quantity > minimum,
                tint: quantity <= minimum && removesAtMinimum ? Theme.danger : Theme.textPrimary,
                action: onDecrement
            )

            Text(quantity, format: .number)
                .font(.system(size: compact ? 14 : 16, weight: .semibold))
                .foregroundStyle(Theme.textPrimary)
                .contentTransition(.numericText())
                .frame(minWidth: compact ? 28 : 36)

            button(
                icon: "plus",
                enabled: quantity < maximum,
                tint: Theme.textPrimary,
                action: onIncrement
            )
        }
        .padding(4)
        .background(Theme.surfaceAlt, in: Capsule())
    }

    private func button(icon: String, enabled: Bool, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: compact ? 11 : 13, weight: .bold))
                .foregroundStyle(enabled ? tint : Theme.textTertiary)
                .frame(width: side, height: side)
                .background(Theme.surface, in: Circle())
        }
        .buttonStyle(.pressable)
        .disabled(!enabled)
    }
}
