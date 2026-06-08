//
//  Plant.swift
//  PP
//
//  Created by Ly Kimheng on 9/4/26.
//
import SwiftUI

struct SpecialPlant: Identifiable, Hashable {
    let id = UUID()
    // ← inherit base info from PlantModel
    let plant: PlantModel
    let discountPrice: Double

    // Forwarded from PlantModel (no rating, no counting)
    var image: String       { plant.image }
    var name: String        { plant.name }
    var type: String        { plant.type }
    var typePlant: String   { plant.typePlant }
    var description: String { plant.description }

    var firstPrice: Double  { plant.price }       // original price (strikethrough)
    var price: Double       { discountPrice }      // discounted price

    var discountPercentage: Int {
        Int((1 - discountPrice / plant.price) * 100)
    }
}

struct SpecialOfferData {
    static let all: [SpecialPlant] = [
        SpecialPlant(plant: PlantData.indoorPlants[0], discountPrice: 3.50),
        SpecialPlant(plant: PlantData.outdoorPlants[0], discountPrice: 5.00),
    ]
}
