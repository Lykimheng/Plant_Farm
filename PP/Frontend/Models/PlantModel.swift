//
//  PlantModel.swift
//  PP
//
//  Created by Ly Kimheng on 14/5/26.
//

import Foundation

nonisolated struct PlantModel: Identifiable, Hashable, Codable {
    let id: Int
    let image: String
    let name: String
    let type: String
    let typePlant: String
    let price: Double
    let description: String
    let rating: Double
    let counting: Int

    enum CodingKeys: String, CodingKey {
        case id, image, name, type, price, description, rating, counting
        case typePlant = "type_plant"
    }

    var category: PlantCategory { PlantCategory(apiValue: typePlant) }
}

// MARK: - Preview sample (SwiftUI previews only, never shipped data)
nonisolated extension PlantModel {
    static let preview = PlantModel(
        id: 0, image: "", name: "Golden Barrel Cactus", type: "Indoor Plant",
        typePlant: "indoorPlant", price: 25.00,
        description: "Adapted to arid environments, this slow-growing cactus asks for little more than a bright windowsill and a drink every few weeks.",
        rating: 4.6, counting: 39
    )
}
