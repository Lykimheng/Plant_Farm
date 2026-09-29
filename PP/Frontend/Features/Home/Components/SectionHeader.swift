//
//  SectionHeader.swift
//  PP
//
//  Created by Ly Kimheng on 12/8/26.
//

import SwiftUI

struct SectionHeader: View {
    let title: LocalizedStringResource
    var isExpanded: Bool = false
    var showsToggle: Bool = true
    var onToggle: () -> Void = {}

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Theme.textPrimary)

            Spacer()

            if showsToggle {
                Button(action: onToggle) {
                    HStack(spacing: 3) {
                        Text(isExpanded ? "See less" : "See all")
                        Image(systemName: isExpanded ? Icons.collapse : Icons.forward)
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Theme.brand)
                }
                .buttonStyle(.pressable)
                .accessibilityLabel(isExpanded ? Text("Collapse \(Text(title))") : Text("Show all \(Text(title))"))
            }
        }
        .padding(.horizontal, Theme.Spacing.lg)
    }
}

#Preview {
    VStack(spacing: 20) {
        SectionHeader(title: "Indoor Plants")
        SectionHeader(title: "Special Offers", isExpanded: true)
    }
    .background(Theme.background)
}
