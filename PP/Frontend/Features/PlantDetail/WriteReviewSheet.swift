//
//  WriteReviewSheet.swift
//  PP
//
//  Created by Ly Kimheng on 7/8/26.
//

import SwiftUI

struct WriteReviewSheet: View {
    let plant: PlantModel
    @ObservedObject var store: ReviewsStore

    @EnvironmentObject private var user: UserStore
    @Environment(\.dismiss) private var dismiss

    @State private var rating = 0
    @State private var body_ = ""
    @State private var showDeleteConfirm = false

    private let characterLimit = 1000
    private var isEditing: Bool { store.myReview != nil }

    private var ratingLabel: LocalizedStringResource {
        switch rating {
        case 1: return "Poor"
        case 2: return "Not great"
        case 3: return "Okay"
        case 4: return "Good"
        case 5: return "Excellent"
        default: return "Tap a star to rate"
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                    plantHeader
                    ratingPicker
                    bodyField

                    InlineError(message: store.errorMessage)

                    if isEditing {
                        deleteButton
                    }
                }
                .padding(Theme.Spacing.lg)
            }
            .background(Theme.background)
            .navigationTitle(isEditing ? "Edit review" : "Write a review")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .disabled(store.isSubmitting)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if store.isSubmitting {
                        ProgressView()
                    } else {
                        Button("Post") { submit() }
                            .fontWeight(.semibold)
                            .disabled(rating == 0)
                    }
                }
            }
            .onAppear {
                if let mine = store.myReview {
                    rating = mine.rating
                    body_ = mine.body ?? ""
                }
                store.errorMessage = nil
            }
            .confirmationDialog(
                "Delete your review?",
                isPresented: $showDeleteConfirm,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) { deleteReview() }
                Button("Keep", role: .cancel) {}
            } message: {
                Text("This removes your rating from \(plant.name).")
            }
        }
    }

    // MARK: - Pieces

    private var plantHeader: some View {
        HStack(spacing: Theme.Spacing.md) {
            RemoteImage(urlString: plant.image)
                .scaledToFill()
                .frame(width: 56, height: 56)
                .clipped()
                .background(Theme.surfaceAlt)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.sm, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(plant.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)
                Text(plant.type)
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.textTertiary)
            }

            Spacer(minLength: 0)
        }
    }

    private var ratingPicker: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Your rating")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Theme.textPrimary)

            VStack(spacing: 8) {
                StarRatingInput(rating: $rating)
                Text(ratingLabel)
                    .font(.system(size: 12))
                    .foregroundStyle(rating == 0 ? Theme.textTertiary : Theme.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.md)
            .cardSurface(padding: Theme.Spacing.sm)
        }
    }

    private var bodyField: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack {
                Text("Your review")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)
                Text("(optional)")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.textTertiary)

                Spacer()

                Text(verbatim: "\(body_.count)/\(characterLimit)")
                    .font(.system(size: 11))
                    .foregroundStyle(body_.count > characterLimit ? Theme.danger : Theme.textTertiary)
            }

            ZStack(alignment: .topLeading) {
                if body_.isEmpty {
                    Text("How is it growing? Anything others should know?")
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.textTertiary)
                        .padding(.top, 8)
                        .padding(.leading, 5)
                }

                TextEditor(text: $body_)
                    .font(.system(size: 13))
                    .frame(height: 130)
                    .scrollContentBackground(.hidden)
            }
            .padding(6)
            .background(Theme.surface, in: RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous)
                    .strokeBorder(Theme.separator, lineWidth: 0.7)
            )
        }
    }

    private var deleteButton: some View {
        Button(role: .destructive) {
            showDeleteConfirm = true
        } label: {
            HStack(spacing: 6) {
                Image(systemName: Icons.trash)
                Text("Delete my review")
            }
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(Theme.danger)
            .frame(maxWidth: .infinity)
            .frame(height: 46)
            .background(Theme.danger.opacity(0.1), in: RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous))
        }
        .buttonStyle(.pressable)
        .disabled(store.isSubmitting)
    }

    // MARK: - Actions

    private func submit() {
        guard rating > 0 else { return }

        Task {
            let ok = await store.submit(
                plantId: plant.id,
                userId: user.id,
                rating: rating,
                body: String(body_.prefix(characterLimit))
            )
            if ok { dismiss() }
        }
    }

    private func deleteReview() {
        Task {
            let ok = await store.deleteMyReview(plantId: plant.id, userId: user.id)
            if ok { dismiss() }
        }
    }
}
