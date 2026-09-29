//
//  PopularSection.swift
//  PP
//
//  Created by Ly Kimheng on 10/1/26.
//

import SwiftUI

struct PopularSection: View {
    @EnvironmentObject private var catalog: PlantsStore

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            SectionHeader(title: "Popular Plants", showsToggle: false)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: Theme.Spacing.md) {
                    ForEach(catalog.popularPlants) { plant in
                        NavigationLink(value: catalog.listing(for: plant)) {
                            PopularPlantCard(plant: plant)
                                .frame(width: 296)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.vertical, 2)
            }
            .scrollClipDisabled()
        }
        .padding(.vertical, Theme.Spacing.lg)
        // full-bleed, so on iPad the band doesn't stop partway through the carousel
        // that scrolls past the content column
        .background { Theme.sectionWash.containerRelativeFrame(.horizontal) }
    }
}

#Preview {
    NavigationStack {
        PopularSection()
            .environmentObject(PlantsStore())
            .environmentObject(CartStore())
            .environmentObject(WishlistStore())
    }
}
