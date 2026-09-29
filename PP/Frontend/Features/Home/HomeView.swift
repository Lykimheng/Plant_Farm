//
//  HomeView.swift
//  PP
//
//  Created by Ly Kimheng on 24/12/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject private var catalog: PlantsStore
    @State private var scrollOffset: CGFloat = 0
    private var isHeaderCollapsed: Bool { scrollOffset > 40 }
    private static let sectionCategories: [PlantCategory] = [.indoor, .outdoor, .aquatic, .bigTree]

    var body: some View {
        ScrollViewReader { proxy in
            VStack(spacing: 0) {
                HomeHeader(
                    searchText: $viewModel.searchText,
                    isCollapsed: isHeaderCollapsed,
                    scrollToTop: {
                        withAnimation { proxy.scrollTo(Self.topAnchor, anchor: .top) }
                    }
                )

                content
            }
        }
        .background(Theme.background)
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(for: PlantListing.self) { listing in
            PlantDetailView(listing: listing)
        }
        .task { await catalog.loadIfNeeded() }
    }

    private static let topAnchor = "home-top"

    // MARK: - Body

    private var content: some View {
        ScrollView {
            LazyVStack(spacing: Theme.Spacing.xl) {
                Color.clear.frame(height: 1).id(Self.topAnchor)

                if viewModel.isSearching {
                    searchResults
                } else {
                    if viewModel.selectedCategory == .all {
                        BannerCarousel()
                            .padding(.horizontal, Theme.Spacing.lg)
                    }

                    categoryChips

                    if catalog.isLoading && !catalog.hasLoaded {
                        SkeletonList(count: 3, height: 150)
                            .padding(.horizontal, Theme.Spacing.lg)
                    } else if catalog.plants.isEmpty {
                        catalogUnavailable
                    } else if viewModel.selectedCategory == .all {
                        browseAll
                    } else {
                        PlantGrid(listings: catalog.listings(in: viewModel.selectedCategory))
                    }
                }
            }
            .padding(.top, Theme.Spacing.lg)
            .padding(.bottom, Theme.Spacing.xxl)
            .readableWidth(Theme.Layout.wide)
        }
        .scrollDismissesKeyboard(.immediately)
        .onScrollGeometryChange(for: CGFloat.self) { geometry in
            geometry.contentOffset.y
        } action: { _, newValue in
            scrollOffset = newValue
        }
        .refreshable { await catalog.load() }
    }

    // MARK: - Sections

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Theme.Spacing.sm) {
                ForEach(PlantCategory.browsable) { category in
                    CategoryChip(
                        title: category.title,
                        isSelected: viewModel.selectedCategory == category
                    ) {
                        viewModel.select(category)
                    }
                }
            }
            .padding(.horizontal, Theme.Spacing.lg)
        }
        .scrollClipDisabled()
    }

    @ViewBuilder
    private var browseAll: some View {
        PlantSection(
            title: "Special Offers",
            listings: catalog.specialOffers,
            isExpanded: viewModel.isOffersExpanded,
            onToggle: viewModel.toggleOffers
        )

        if !catalog.popularPlants.isEmpty {
            PopularSection()
        }

        ForEach(Self.sectionCategories) { category in
            PlantSection(
                title: category.sectionTitle,
                listings: catalog.listings(in: category),
                isExpanded: viewModel.isExpanded(category),
                onToggle: { viewModel.toggle(category) }
            )
        }

        AboutUsSection()

        VStack(spacing: Theme.Spacing.md) {
            PerkCard(icon: Icons.verified, title: "Membership", subtitle: "20% off every purchase.")
            PerkCard(icon: "ticket", title: "Five free coupons", subtitle: "A welcome gift for new gardeners.")
            PerkCard(icon: Icons.truck, title: "Free delivery", subtitle: "On any address within 3 km.")
        }
        .padding(.horizontal, Theme.Spacing.lg)
    }

    @ViewBuilder
    private var searchResults: some View {
        let results = catalog.search(viewModel.searchText)

        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text(
                results.isEmpty
                ? "No matches for \u{201C}\(viewModel.searchText.trimmed)\u{201D}"
                : "^[\(results.count) result](inflect: true) for \u{201C}\(viewModel.searchText.trimmed)\u{201D}"
            )
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(Theme.textSecondary)
            .padding(.horizontal, Theme.Spacing.lg)

            if results.isEmpty {
                EmptyStateView(
                    icon: Icons.search,
                    title: "No plants found",
                    message: "Try a different name, or browse a category instead.",
                    actionTitle: "Clear search",
                    action: viewModel.clearSearch
                )
            } else {
                PlantGrid(listings: catalog.listings(for: results))
            }
        }
    }

    private var catalogUnavailable: some View {
        EmptyStateView(
            icon: "wifi.exclamationmark",
            title: "Couldn't load the shop",
            message: catalog.errorMessage ?? "Pull down to try again.",
            actionTitle: "Try again",
            action: { Task { await catalog.load() } }
        )
    }
}

#Preview {
    NavigationStack {
        HomeView()
            .environmentObject(PlantsStore())
            .environmentObject(CartStore())
            .environmentObject(WishlistStore())
            .environmentObject(UserStore())
            .environmentObject(LocationManager())
            .environmentObject(NotificationsStore())
    }
}
