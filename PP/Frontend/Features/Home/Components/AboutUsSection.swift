//
//  AboutUsSection.swift
//  PP
//
//  Created by Ly Kimheng on 22/1/26.
//


import SwiftUI

struct AboutUsSection: View {
    @State private var showHelp = false

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("We're here to help you")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Theme.textPrimary)

            Text("New to plants? Our care guides cover watering, light and the first month with a new pot.")
                .font(.system(size: 13.5))
                .foregroundStyle(Theme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Button {
                showHelp = true
            } label: {
                HStack(spacing: 5) {
                    Text("Explore care guides")
                    Image(systemName: Icons.forward)
                        .font(.system(size: 11, weight: .semibold))
                }
            }
            .buttonStyle(SecondaryButtonStyle(fullWidth: false))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Theme.Spacing.lg)
        .background(Theme.sectionWash, in: RoundedRectangle(cornerRadius: Theme.Radius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.lg, style: .continuous)
                .strokeBorder(Theme.separator, lineWidth: 0.7)
        )
        .padding(.horizontal, Theme.Spacing.lg)
        .sheet(isPresented: $showHelp) {
            NavigationStack { HelpView(isModal: true) }
        }
    }
}

#Preview {
    AboutUsSection()
        .background(Theme.background)
}
