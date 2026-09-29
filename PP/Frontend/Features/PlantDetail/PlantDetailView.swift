//
//  PlantDetailView.swift
//  PP
//
//  Created by Ly Kimheng on 10/9/26.
//

import SwiftUI

struct PlantDetailView: View {
    let listing: PlantListing

    @EnvironmentObject private var cart: CartStore
    @EnvironmentObject private var user: UserStore
    @Environment(\.dismiss) private var dismiss

    @StateObject private var reviews = ReviewsStore()
    @State private var quantity = 1
    @State private var isDescriptionExpanded = false
    @State private var showWriteReview = false
    @State private var scrollOffset: CGFloat = 0

    private var plant: PlantModel { listing.plant }
    private var lineTotal: Double { listing.price * Double(quantity) }
    private var savings: Double { listing.savings * Double(quantity) }

    var body: some View {
        GeometryReader { proxy in
            scrollContent(topInset: proxy.safeAreaInsets.top)
        }
        .background(Theme.background)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar, .tabBar)
        .safeAreaInset(edge: .bottom) { bottomBar }
        // back / wishlist stay reachable however far the page is scrolled
        .overlay(alignment: .top) { topBar }
        .sheet(isPresented: $showWriteReview) {
            WriteReviewSheet(plant: plant, store: reviews)
        }
        .task { await reviews.load(plantId: plant.id, userId: user.id) }
    }

    private func scrollContent(topInset: CGFloat) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                hero(topInset: topInset)

                VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                    infoBlock
                    quantityBlock
                    descriptionBlock
                    careBlock
                    ReviewsSection(plant: plant, store: reviews, showWriteSheet: $showWriteReview)
                }
                .readableWidth()
            }
            .padding(.bottom, Theme.Spacing.xxl)
        }
        .ignoresSafeArea(edges: .top)
        .onScrollGeometryChange(for: CGFloat.self) { geometry in
            geometry.contentOffset.y
        } action: { _, newValue in
            scrollOffset = newValue
        }
    }
    
    private var topBar: some View {
        floatingControls
            .background(alignment: .top) {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .opacity(scrimOpacity)
                    .ignoresSafeArea(edges: .top)
                    .allowsHitTesting(false)
            }
    }

    private var scrimOpacity: Double {
        min(max((scrollOffset - 230) / 60, 0), 1)
    }

    // MARK: - Hero

    private func hero(topInset: CGFloat) -> some View {
        RemoteImage(urlString: listing.image)
            .scaledToFit()
            .padding(.horizontal, Theme.Spacing.xl)
            .padding(.top, topInset + Theme.Spacing.xxl)
            .padding(.bottom, Theme.Spacing.xl)
            .frame(maxWidth: .infinity)
            .frame(height: 340 + topInset)
            .background(Theme.brandTint)
            .overlay(alignment: .bottomLeading) { offerBadge }
    }

    private var floatingControls: some View {
        HStack {
            circleButton(Icons.back, label: "Back") { dismiss() }
            Spacer()
            WishlistToggleButton(plant: plant, style: .prominent)
        }
        .padding(.horizontal, Theme.Spacing.lg)
        .padding(.vertical, Theme.Spacing.sm)
    }

    @ViewBuilder
    private var offerBadge: some View {
        if listing.isDiscounted {
            Text("\(listing.discountPercentage)% OFF")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Theme.onBrand)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Theme.danger, in: Capsule())
                .padding(.leading, Theme.Spacing.lg)
                .padding(.bottom, Theme.Spacing.md)
        }
    }

    private func circleButton(_ systemName: String, label: LocalizedStringResource, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Theme.textPrimary)
                .frame(width: 40, height: 40)
                .background(Theme.surface.opacity(0.92), in: Circle())
                .overlay(Circle().strokeBorder(Theme.separator, lineWidth: 0.7))
        }
        .buttonStyle(.pressable)
        .accessibilityLabel(Text(label))
    }

    // MARK: - Info

    private var infoBlock: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text(listing.type.uppercased())
                .font(.system(size: 10, weight: .semibold))
                .tracking(0.6)
                .foregroundStyle(Theme.textTertiary)

            Text(listing.name)
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(Theme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            RatingView(
                rating: displayedRating,
                reviewsCount: displayedReviewCount,
                starSize: 13
            )

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(listing.price.priceText)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Theme.brand)

                if let originalPrice = listing.originalPrice {
                    Text(originalPrice.priceText)
                        .font(.system(size: 15))
                        .foregroundStyle(Theme.textTertiary)
                        .strikethrough(true, color: Theme.textTertiary)
                }
            }
            .padding(.top, 2)

            if listing.isDiscounted {
                Text("You save \(listing.savings.priceText) per plant")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Theme.success)
            }
        }
        .padding(.horizontal, Theme.Spacing.lg)
    }

    private var displayedRating: Double {
        reviews.summary.reviewsCount > 0 ? reviews.summary.rating : plant.rating
    }

    private var displayedReviewCount: Int {
        reviews.summary.reviewsCount > 0 ? reviews.summary.reviewsCount : plant.counting
    }

    // MARK: - Quantity

    private var quantityBlock: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Quantity")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)
                Text("Up to \(CartStore.maximumPerLine) per order")
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.textTertiary)
            }

            Spacer()

            QuantityStepper(
                quantity: quantity,
                minimum: 1,
                maximum: CartStore.maximumPerLine,
                removesAtMinimum: false,
                onDecrement: { quantity = max(1, quantity - 1) },
                onIncrement: { quantity = min(CartStore.maximumPerLine, quantity + 1) }
            )
        }
        .cardSurface(padding: Theme.Spacing.md)
        .padding(.horizontal, Theme.Spacing.lg)
    }

    // MARK: - Description

    private var descriptionBlock: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Description")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Theme.textPrimary)

            Text(listing.description)
                .font(.system(size: 13.5))
                .foregroundStyle(Theme.textSecondary)
                .lineSpacing(3)
                .lineLimit(isDescriptionExpanded ? nil : 4)
                .fixedSize(horizontal: false, vertical: true)

            if listing.description.count > 160 {
                Button(isDescriptionExpanded ? "Show less" : "Read more") {
                    withAnimation(.easeInOut(duration: 0.2)) { isDescriptionExpanded.toggle() }
                }
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Theme.brand)
            }
        }
        .padding(.horizontal, Theme.Spacing.lg)
    }

    // MARK: - Care

    private var careBlock: some View {
        HStack(spacing: Theme.Spacing.md) {
            careTile(icon: Icons.waterFilled, title: "Water", value: "Weekly")
            careTile(icon: Icons.sun, title: "Light", value: "Bright")
            careTile(icon: Icons.myPlants, title: "Care", value: "Easy")
        }
        .padding(.horizontal, Theme.Spacing.lg)
    }

    private func careTile(icon: String, title: LocalizedStringResource, value: LocalizedStringResource) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(Theme.brand)
            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Theme.textPrimary)
            Text(title)
                .font(.system(size: 11))
                .foregroundStyle(Theme.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Spacing.md)
        .cardBackground(radius: Theme.Radius.md)
        .accessibilityElement(children: .combine)
    }

    // MARK: - Bottom bar

    private var bottomBar: some View {
        HStack(spacing: Theme.Spacing.lg) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Total")
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.textTertiary)
                Text(lineTotal.priceText)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)
                    .contentTransition(.numericText())
                if savings > 0 {
                    Text("Saving \(savings.priceText)")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(Theme.success)
                }
            }

            Button("Add to Cart") {
                cart.add(listing.purchasable, quantity: quantity)
            }
            .buttonStyle(.primary)
        }
        .padding(.horizontal, Theme.Spacing.lg)
        .padding(.vertical, Theme.Spacing.md)
        .readableWidth()
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) {
            Rectangle().fill(Theme.separator).frame(height: 0.7)
        }
    }
}

#Preview {
    NavigationStack {
        PlantDetailView(listing: PlantListing(.preview, discountPrice: 18))
            .environmentObject(CartStore())
            .environmentObject(WishlistStore())
            .environmentObject(UserStore())
    }
}
