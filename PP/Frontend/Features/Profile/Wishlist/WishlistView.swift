//
//  WishlistView.swift
//  PP
//
//  Created by Ly Kimheng on 8/6/26.
//

import SwiftUI

struct WishlistView: View {
    var isModal: Bool = false
    @EnvironmentObject private var catalog: PlantsStore
    @EnvironmentObject private var wishlist: WishlistStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Group {
            if wishlist.isEmpty {
                EmptyStateView(
                    icon: "heart.slash",
                    title: "No plants saved yet",
                    message: "Tap the heart on any plant to keep it here for later."
                )
                .frame(maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                        Text("^[\(wishlist.items.count) plant](inflect: true) saved for later")
                            .font(.system(size: 13))
                            .foregroundStyle(Theme.textSecondary)
                            .padding(.horizontal, Theme.Spacing.lg)

                        LazyVGrid(columns: .plantGrid, spacing: Theme.Spacing.lg) {
                            ForEach(wishlist.items) { plant in
                                NavigationLink(value: catalog.listing(for: plant)) {
                                    WishlistCard(plant: plant)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, Theme.Spacing.lg)
                    }
                    .padding(.vertical, Theme.Spacing.md)
                    .readableWidth(760)
                }
            }
        }
        .background(Theme.background)
        .navigationTitle("Wishlist")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: PlantListing.self) { listing in
            PlantDetailView(listing: listing)
        }
        .toolbar {
            if isModal {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { dismiss() }
                }
            }
            if !wishlist.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Clear", role: .destructive) {
                        withAnimation { wishlist.clear() }
                    }
                    .tint(Theme.danger)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        WishlistView()
            .environmentObject(WishlistStore())
            .environmentObject(CartStore())
            .environmentObject(UserStore())
            .environmentObject(PlantsStore())
    }
}
