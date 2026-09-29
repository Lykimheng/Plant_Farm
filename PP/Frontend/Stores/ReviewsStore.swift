//
//  ReviewsStore.swift
//  PP
//
//  Created by Ly Kimheng on 12/8/26.
//

import SwiftUI
import Combine

@MainActor
final class ReviewsStore: ObservableObject {
    @Published private(set) var summary: ReviewSummary = .empty
    @Published private(set) var reviews: [ReviewModel] = []
    @Published private(set) var myReview: ReviewModel?
    @Published private(set) var myReviewHidden = false
    @Published private(set) var canReview = false
    @Published private(set) var isLoading = false
    @Published private(set) var isSubmitting = false
    @Published var errorMessage: LocalizedStringResource?

    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    var othersReviews: [ReviewModel] { reviews.filter { !$0.isMine } }

    var isEmpty: Bool { reviews.isEmpty && myReview == nil }

    func load(plantId: Int, userId: Int) async {
        isLoading = true
        defer { isLoading = false }

        do {
            let payload: ReviewsPayload = try await client.get(
                API.Path.reviews,
                query: ["plant_id": String(plantId), "user_id": String(userId)]
            )
            apply(payload)
        } catch {
            errorMessage = error.userMessage
            AppLog.network("load reviews", error)
        }
    }

    func submit(plantId: Int, userId: Int, rating: Int, body: String) async -> Bool {
        await write {
            try await self.client.send(
                API.Path.reviews,
                method: .post,
                body: SubmitReviewRequest(
                    plantId: plantId,
                    userId: userId,
                    rating: rating,
                    body: body.trimmed
                )
            )
        }
    }

    func deleteMyReview(plantId: Int, userId: Int) async -> Bool {
        guard let myReview else { return false }

        return await write {
            try await self.client.send(
                API.Path.reviews,
                method: .delete,
                body: DeleteReviewRequest(plantId: plantId, userId: userId, reviewId: myReview.id)
            )
        }
    }

    private func write(_ request: () async throws -> ReviewsPayload) async -> Bool {
        isSubmitting = true
        defer { isSubmitting = false }

        do {
            apply(try await request())
            errorMessage = nil
            return true
        } catch {
            errorMessage = error.userMessage
            AppLog.network("submit review", error)
            return false
        }
    }

    private func apply(_ payload: ReviewsPayload) {
        summary = payload.summary
        reviews = payload.reviews
        myReview = payload.myReview
        myReviewHidden = payload.myReviewHidden
        canReview = payload.canReview
    }
}
