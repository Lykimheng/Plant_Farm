//
//  PlantSection.swift
//  PP
//
//  Created by Ly Kimheng on 12/8/26.
//

import SwiftUI

struct PlantSection: View {
    let title: String
    let listings: [PlantListing]
    let isExpanded: Bool
    let onToggle: () -> Void

    

    var body: some View {
        if !listings.isEmpty {
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                SectionHeader(
                    title: title,
                    isExpanded: isExpanded,
                    showsToggle: listings.count > 2,
                    onToggle: onToggle
                )

                if isExpanded {
                    LazyVGrid(columns: .plantGrid, spacing: Theme.Spacing.lg) {
                        ForEach(listings) { listing in
                            PlantLink(listing: listing)
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.lg)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: Theme.Spacing.md) {
                            ForEach(listings) { listing in
                                PlantLink(listing: listing)
                                    .frame(width: 168)
                            }
                        }
                        .padding(.horizontal, Theme.Spacing.lg)
                        .padding(.vertical, 2)
                    }
                    .scrollClipDisabled()
                }
            }
        }
    }
}

struct PlantLink: View {
    let listing: PlantListing

    var body: some View {
        NavigationLink(value: listing) {
            PlantGridCard(listing: listing)
        }
        .buttonStyle(.plain)
    }
}

/// Two-column grid used by search results and the filtered category view.
struct PlantGrid: View {
    let listings: [PlantListing]

    

    var body: some View {
        LazyVGrid(columns: .plantGrid, spacing: Theme.Spacing.lg) {
            ForEach(listings) { listing in
                PlantLink(listing: listing)
            }
        }
        .padding(.horizontal, Theme.Spacing.lg)
    }
}
