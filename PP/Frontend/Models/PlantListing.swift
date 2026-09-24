//
//  PlantListing.swift
//  PP
//
//  Created by Ly Kimheng on 12/8/26.
//

import Foundation

nonisolated struct PlantListing: Identifiable, Hashable {
    let plant: PlantModel
    let discountPrice: Double?
    var id: Int { plant.id }
    init(_ plant: PlantModel, discountPrice: Double? = nil) {
        self.plant = plant
        self.discountPrice = discountPrice.flatMap { $0 < plant.price ? $0 : nil }
    }

    var isDiscounted: Bool { discountPrice != nil }
    
    var price: Double { discountPrice ?? plant.price }
    
    var originalPrice: Double? { isDiscounted ? plant.price : nil }
    
    var savings: Double { plant.price - price }
    
    var discountPercentage: Int {
        guard isDiscounted, plant.price > 0 else { return 0 }
        return Int(((plant.price - price) / plant.price * 100).rounded())
    }
    
    var purchasable: PlantModel {
        guard isDiscounted else { return plant }
        return PlantModel(
            id: plant.id,
            image: plant.image,
            name: plant.name,
            type: plant.type,
            typePlant: plant.typePlant,
            price: price,
            description: plant.description,
            rating: plant.rating,
            counting: plant.counting
        )
    }

    var name: String { plant.name }
    var image: String { plant.image }
    var type: String { plant.type }
    var typePlant: String { plant.typePlant }
    var description: String { plant.description }
}

nonisolated extension PlantModel {
    var listing: PlantListing { PlantListing(self) }
}
