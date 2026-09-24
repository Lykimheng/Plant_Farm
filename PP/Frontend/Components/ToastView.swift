//
//  ToastView.swift
//  PP
//
//  Created by Ly Kimheng on 29/5/26.
//

import SwiftUI

struct ToastView: View {
    let message: String

    var body: some View {
        HStack(spacing: Theme.Spacing.sm) {
            Image(systemName: Icons.cartAdd)
                .font(.system(size: 15, weight: .semibold))
            Text(message)
                .font(.system(size: 14, weight: .semibold))
                .lineLimit(2)
        }
        .foregroundStyle(Theme.onBrand)
        .padding(.horizontal, Theme.Spacing.lg)
        .padding(.vertical, Theme.Spacing.md)
        .background(Theme.brand, in: Capsule())
        .softShadow(radius: 12, y: 6)
        .padding(.horizontal, Theme.Spacing.lg)
    }
}

extension View {
    func toast(center: ToastCenter) -> some View {
        overlay(alignment: .top) {
            if center.isShowing {
                ToastView(message: center.message)
                    .padding(.top, Theme.Spacing.sm)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .onTapGesture { center.dismiss() }
                    .accessibilityAddTraits(.isStaticText)
            }
        }
    }
}

#Preview {
    Color.gray.toast(center: {
        let center = ToastCenter()
        center.show("Golden Barrel Cactus added to cart")
        return center
    }())
}
