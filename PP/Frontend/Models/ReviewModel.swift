//
//  ReviewModel.swift
//  PP
//
//  Created by Ly Kimheng on 12/8/26.
//

import Foundation

nonisolated struct ReviewModel: Identifiable, Hashable, Decodable {
    let id: Int
    let rating: Int
    let body: String?
    let authorName: String
    let authorAvatar: String
    let isMine: Bool
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id, rating, body
        case authorName = "author_name"
        case authorAvatar = "author_avatar"
        case isMine = "is_mine"
        case createdAt = "created_at"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        rating = try container.decodeIfPresent(Int.self, forKey: .rating) ?? 0
        body = try container.decodeIfPresent(String.self, forKey: .body)
        authorName = try container.decodeIfPresent(String.self, forKey: .authorName) ?? "Someone"
        authorAvatar = try container.decodeIfPresent(String.self, forKey: .authorAvatar) ?? ""
        isMine = try container.decodeIfPresent(Bool.self, forKey: .isMine) ?? false
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
    }

    var hasBody: Bool { !(body ?? "").isBlank }

    var initials: String {
        let letters = authorName.split(separator: " ").prefix(2).compactMap(\.first).map(String.init)
        return letters.isEmpty ? "?" : letters.joined().uppercased()
    }

    var relativeDate: String {
        guard let createdAt else { return "" }
        let date = OrderDateFormat.parse(createdAt)

        if Date().timeIntervalSince(date) < 60 { return "Just now" }

        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

nonisolated struct ReviewSummary: Decodable, Hashable {
    let rating: Double
    let reviewsCount: Int
    let distribution: [String: Int]
    let hasRating: Bool

    static let empty = ReviewSummary(rating: 0, reviewsCount: 0, distribution: [:], hasRating: false)

    init(rating: Double, reviewsCount: Int, distribution: [String: Int], hasRating: Bool) {
        self.rating = rating
        self.reviewsCount = reviewsCount
        self.distribution = distribution
        self.hasRating = hasRating
    }

    enum CodingKeys: String, CodingKey {
        case rating, distribution
        case reviewsCount = "reviews_count"
        case hasRating = "has_rating"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        rating = try container.decodeIfPresent(Double.self, forKey: .rating) ?? 0
        reviewsCount = try container.decodeIfPresent(Int.self, forKey: .reviewsCount) ?? 0
        distribution = try container.decodeIfPresent([String: Int].self, forKey: .distribution) ?? [:]
        hasRating = try container.decodeIfPresent(Bool.self, forKey: .hasRating) ?? false
    }

    func count(forStar star: Int) -> Int { distribution["\(star)"] ?? 0 }

    func share(forStar star: Int) -> Double {
        guard reviewsCount > 0 else { return 0 }
        return Double(count(forStar: star)) / Double(reviewsCount)
    }

    var countText: String {
        "\(reviewsCount) review\(reviewsCount == 1 ? "" : "s")"
    }
}

nonisolated struct ReviewsPayload: APIResponse {
    let success: Bool
    let message: String?
    let summary: ReviewSummary
    let reviews: [ReviewModel]
    let myReview: ReviewModel?
    let myReviewHidden: Bool
    let canReview: Bool

    enum CodingKeys: String, CodingKey {
        case success, message, summary, reviews
        case myReview = "my_review"
        case myReviewHidden = "my_review_hidden"
        case canReview = "can_review"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        success = try container.decodeIfPresent(Bool.self, forKey: .success) ?? true
        message = try container.decodeIfPresent(String.self, forKey: .message)
        summary = try container.decodeIfPresent(ReviewSummary.self, forKey: .summary) ?? .empty
        reviews = try container.decodeIfPresent([ReviewModel].self, forKey: .reviews) ?? []
        myReview = try container.decodeIfPresent(ReviewModel.self, forKey: .myReview)
        myReviewHidden = try container.decodeIfPresent(Bool.self, forKey: .myReviewHidden) ?? false
        canReview = try container.decodeIfPresent(Bool.self, forKey: .canReview) ?? false
    }
}
