//
//  PerkCard.swift
//  PP
//
//  Created by Ly Kimheng on 12/8/26.
//

import SwiftUI

struct PerkCard: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: Theme.Spacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Theme.brand)
                .frame(width: 44, height: 44)
                .background(Theme.brandTint, in: RoundedRectangle(cornerRadius: Theme.Radius.sm, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)
                Text(subtitle)
                    .font(.system(size: 12.5))
                    .foregroundStyle(Theme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .cardSurface(padding: Theme.Spacing.md)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    VStack(spacing: 12) {
        PerkCard(icon: Icons.verified, title: "Membership", subtitle: "20% off every purchase.")
        PerkCard(icon: Icons.truck, title: "Free delivery", subtitle: "On any address within 3 km.")
    }
    .padding()
    .background(Theme.background)
}
