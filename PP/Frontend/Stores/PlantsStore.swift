//
//  PlantsModel.swift
//  PP
//
//  Created by Ly Kimheng on 20/6/26.
//

import SwiftUI
import Combine

// MARK: - Raw API row (includes marketing flags not part of PlantModel)
private struct PlantAPIModel: Codable {
    let id: Int
    let image: String
    let name: String
    let type: String
    let typePlant: String
    let price: Double
    let description: String
    let rating: Double
    let counting: Int
    let isPopular: Bool
    let discountPrice: Double?

    enum CodingKeys: String, CodingKey {
        case id, image, name, type, price, description, rating, counting
        case typePlant = "type_plant"
        case isPopular = "is_popular"
        case discountPrice = "discount_price"
    }

    func toPlantModel() -> PlantModel {
        PlantModel(
            id: id, image: image, name: name, type: type,
            typePlant: typePlant, price: price,
            description: description, rating: rating, counting: counting
        )
    }
}

private struct PlantsResponse: Codable {
    let success: Bool
    let plants: [PlantAPIModel]
}

class PlantsModel: ObservableObject {
    @Published var plants: [PlantModel] = []
    @Published var popularPlants: [PlantModel] = []
    @Published var specialOffers: [SpecialPlant] = []
    @Published var isLoading = false

    var indoorPlants: [PlantModel]  { plants.filter { $0.typePlant == "indoorPlant" } }
    var outdoorPlants: [PlantModel] { plants.filter { $0.typePlant == "outdoorPlant" } }
    var aquaticPlants: [PlantModel] { plants.filter { $0.typePlant == "aquaticPlant" } }
    var bigTrees: [PlantModel]      { plants.filter { $0.typePlant == "bigTree" } }

    // MARK: - Fetch from API
    func fetchPlants() async {
        await MainActor.run { isLoading = true }

        guard let url = URL(string: "\(APIService.shared.baseURL)/plants.php") else {
            await MainActor.run { isLoading = false }
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(PlantsResponse.self, from: data)

            await MainActor.run {
                self.plants = response.plants.map { $0.toPlantModel() }
                self.popularPlants = response.plants
                    .filter { $0.isPopular }
                    .map { $0.toPlantModel() }
                self.specialOffers = response.plants.compactMap { row in
                    guard let discountPrice = row.discountPrice else { return nil }
                    return SpecialPlant(plant: row.toPlantModel(), discountPrice: discountPrice)
                }
                self.isLoading = false
            }
        } catch {
            await MainActor.run { isLoading = false }
            print("Fetch plants error: \(error)")
        }
    }
}
