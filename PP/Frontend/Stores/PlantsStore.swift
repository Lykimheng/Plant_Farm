//
//  PlantsStore.swift
//  PP
//
//  Created by Ly Kimheng on 12/8/26.
//

import SwiftUI
import Combine

@MainActor
final class PlantsStore: ObservableObject {
    @Published private(set) var plants: [PlantModel] = []
    @Published private(set) var popularPlants: [PlantModel] = []
    @Published private(set) var specialOffers: [PlantListing] = []
    @Published private(set) var byCategory: [PlantCategory: [PlantModel]] = [:]
    @Published private(set) var discounts: [Int: Double] = [:]
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: LocalizedStringResource?

    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    var hasLoaded: Bool { !plants.isEmpty }

    func plants(in category: PlantCategory) -> [PlantModel] {
        category == .all ? plants : (byCategory[category] ?? [])
    }
    
    func listing(for plant: PlantModel) -> PlantListing {
        PlantListing(plant, discountPrice: discounts[plant.id])
    }

    func listings(in category: PlantCategory) -> [PlantListing] {
        plants(in: category).map(listing(for:))
    }

    func listings(for plants: [PlantModel]) -> [PlantListing] {
        plants.map(listing(for:))
    }
    
    func search(_ query: String) -> [PlantModel] {
        let term = query.trimmed
        guard !term.isEmpty else { return [] }
        return plants.filter {
            $0.name.localizedCaseInsensitiveContains(term) ||
            $0.type.localizedCaseInsensitiveContains(term)
        }
    }

    func plants(matching species: PlantSpecies) -> [PlantModel] {
        plants.filter { plant in
            species.catalogKeywords.contains { plant.name.localizedCaseInsensitiveContains($0) }
        }
    }

    func loadIfNeeded() async {
        guard plants.isEmpty else { return }
        await load()
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let response: PlantsResponse = try await client.get(API.Path.plants)
            apply(response.plants)
            errorMessage = nil
        } catch {
            errorMessage = error.userMessage
        }
    }

    private func apply(_ rows: [PlantDTO]) {
        plants = rows.map(\.plant)
        popularPlants = rows.filter(\.isPopular).map(\.plant)
        specialOffers = rows.compactMap(\.specialOffer)

        byCategory = Dictionary(
            grouping: rows.map(\.plant),
            by: { PlantCategory(apiValue: $0.typePlant) }
        )

        discounts = rows.reduce(into: [:]) { result, row in
            if let offer = row.specialOffer { result[offer.id] = offer.price }
        }
    }
}
