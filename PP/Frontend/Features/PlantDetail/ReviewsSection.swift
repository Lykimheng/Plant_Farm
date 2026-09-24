//
//  ReviewsSection.swift
//  PP
//
//  Created by Ly Kimheng on 7/8/26.
//

import SwiftUI

struct ReviewsSection: View {
    let plant: PlantModel
    @ObservedObject var store: ReviewsStore
    @Binding var showWriteSheet: Bool

    @EnvironmentObject private var user: UserStore

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Ratings & Reviews")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Theme.textPrimary)

            if store.isLoading && store.isEmpty {
                loadingPlaceholder
            } else if store.isEmpty {
                firstReviewInvite
            } else {
                scoreBlock
                reviewList
            }

            actionButton
        }
        .padding(.horizontal, Theme.Spacing.lg)
    }

    // MARK: - Nobody has reviewed it yet

    private var firstReviewInvite: some View {
        VStack(spacing: 6) {
            Image(systemName: "star.bubble")
                .font(.system(size: 28))
                .foregroundStyle(Theme.textTertiary)
            Text("No reviews yet")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Theme.textPrimary)
            Text("Be the first to share how this plant is doing.")
                .font(.system(size: 12))
                .foregroundStyle(Theme.textTertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Spacing.lg)
        .cardSurface(padding: Theme.Spacing.md)
    }

    // MARK: - Score

    private var scoreBlock: some View {
        HStack(alignment: .center, spacing: Theme.Spacing.lg) {
            VStack(spacing: 3) {
                Text(String(format: "%.1f", store.summary.rating))
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)
                StarRow(rating: store.summary.rating, size: 11)
                Text(store.summary.countText)
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.textTertiary)
            }
            .frame(width: 86)

            RatingBreakdown(summary: store.summary)
        }
        .cardSurface(padding: Theme.Spacing.md)
    }

    // MARK: - List

    private var reviewList: some View {
        VStack(spacing: Theme.Spacing.sm) {
            if let mine = store.myReview {
                ReviewRow(review: mine, isHidden: store.myReviewHidden) {
                    showWriteSheet = true
                }
            }

            ForEach(store.othersReviews) { review in
                ReviewRow(review: review, isHidden: false, onEdit: nil)
            }
        }
    }

    private var loadingPlaceholder: some View {
        SkeletonList(count: 2, height: 76)
    }

    // MARK: - Action

    @ViewBuilder
    private var actionButton: some View {
        if user.isLoggedIn {
            Button {
                showWriteSheet = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: store.myReview == nil ? Icons.edit : Icons.pencil)
                    Text(store.myReview == nil ? "Write a review" : "Edit your review")
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Theme.brand)
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(Theme.brandTint, in: RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous))
            }
            .buttonStyle(.pressable)
        } else {
            HStack(spacing: 6) {
                Image(systemName: Icons.userCircle)
                Text("Sign in to leave a review")
            }
            .font(.system(size: 13))
            .foregroundStyle(Theme.textTertiary)
            .frame(maxWidth: .infinity)
            .frame(height: 46)
            .background(Theme.surfaceAlt, in: RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous))
        }
    }
}

// MARK: - Row

struct ReviewRow: View {
    let review: ReviewModel
    var isHidden: Bool = false
    var onEdit: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                avatar

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(review.isMine ? "You" : review.authorName)
                            .font(.system(size: 13.5, weight: .semibold))
                            .foregroundStyle(Theme.textPrimary)
                            .lineLimit(1)

                        if isHidden {
                            Text("Hidden")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(Theme.danger)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Theme.danger.opacity(0.12), in: Capsule())
                        }
                    }

                    HStack(spacing: 6) {
                        StarRow(rating: Double(review.rating), size: 10)
                        Text(review.relativeDate)
                            .font(.system(size: 11))
                            .foregroundStyle(Theme.textTertiary)
                    }
                }

                Spacer(minLength: 0)

                if let onEdit {
                    Button(action: onEdit) {
                        Image(systemName: Icons.pencil)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Theme.textTertiary)
                            .frame(width: 26, height: 26)
                            .background(Theme.surfaceAlt, in: Circle())
                    }
                    .buttonStyle(.pressable)
                    .accessibilityLabel("Edit your review")
                }
            }

            if review.hasBody {
                Text(review.body ?? "")
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.textSecondary)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if isHidden {
                Text("An admin hid this review, so it isn't shown to others or counted in the rating.")
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.textTertiary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface(padding: Theme.Spacing.md)
    }

    private var avatar: some View {
        Group {
            if review.authorAvatar.isEmpty {
                Circle()
                    .fill(Theme.brandTint)
                    .overlay(
                        Text(review.initials)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Theme.brand)
                    )
            } else {
                RemoteImage(urlString: review.authorAvatar)
                    .scaledToFill()
                    .clipShape(Circle())
            }
        }
        .frame(width: 34, height: 34)
    }
}
