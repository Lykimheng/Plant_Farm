//
//  Plant.swift
//  PP
//
//  Created by Ly Kimheng on 14/5/26.
//

import SwiftUI

struct PlantModel: Identifiable, Hashable, Codable {
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
}

// MARK: - Preview sample (SwiftUI previews only, not used by the app)
extension PlantModel {
    static let preview = PlantModel(
        id: 0, image: "Cactus", name: "Cactus", type: "Indoor Plant",
        typePlant: "indoorPlant", price: 5.00,
        description: "Adapted to arid environments...", rating: 5.0, counting: 39
    )
}
