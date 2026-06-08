//
//  Plant.swift
//  PP
//
//  Created by Ly Kimheng on 14/5/26.
//
import SwiftUI

struct PlantModel: Identifiable, Hashable {
    let id: UUID
    let image: String
    let name: String
    let type: String
    let typePlant: String
    let price: Double
    let description: String
    let rating: Double
    let counting: Int
    
    init(id: UUID = UUID(), image: String, name: String, type: String,
         typePlant: String, price: Double, description: String,
         rating: Double, counting: Int) {
        self.id = id
        self.image = image
        self.name = name
        self.type = type
        self.typePlant = typePlant
        self.price = price
        self.description = description
        self.rating = rating
        self.counting = counting
    }
}

struct PlantData {
    static let indoorPlants: [PlantModel] = [
        PlantModel(id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!, image: "Cactus", name: "Cactus", type: "Indoor Plant", typePlant: "indoorPlant",
            price: 5.00, description: "Adapted to arid environments...", rating: 5.0, counting: 39),
        PlantModel(id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!, image: "Cactus", name: "Cactus", type: "Indoor Plant", typePlant: "indoorPlant",
            price: 5.00, description: "Adapted to arid environments...", rating: 5.0, counting: 39),
        PlantModel(id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,image: "Cactus", name: "Cactus", type: "Indoor Plant", typePlant: "indoorPlant",
            price: 5.00, description: "Adapted to arid environments...", rating: 5.0, counting: 39),
        PlantModel(id: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!,image: "Cactus", name: "Cactus", type: "Indoor Plant", typePlant: "indoorPlant",
            price: 5.00, description: "Adapted to arid environments...", rating: 5.0, counting: 39),
        PlantModel(id: UUID(uuidString: "00000000-0000-0000-0000-000000000005")!,image: "Cactus", name: "Cactus", type: "Indoor Plant", typePlant: "indoorPlant",price: 5.00, description: "Adapted to arid environments...", rating: 5.0, counting: 39),
        PlantModel(id: UUID(uuidString: "00000000-0000-0000-0000-000000000006")!,image: "Cactus", name: "Cactus", type: "Indoor Plant", typePlant: "indoorPlant",
            price: 5.00, description: "Adapted to arid environments...", rating: 5.0, counting: 39),
    ]

    static let outdoorPlants: [PlantModel] = [
        PlantModel(id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,image: "Showy Spindletree Euonymus japonicus", name: "Showy Spindletree Euonymus japonicus", type: "Outdoor Plant", typePlant: "outdoorPlant",price: 7.00, description: "Aromatic flowering plant...", rating: 4.9, counting: 45),
        PlantModel(id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,image: "Showy Spindletree Euonymus japonicus", name: "Showy Spindletree Euonymus japonicus", type: "Outdoor Plant", typePlant: "outdoorPlant",price: 7.00, description: "Aromatic flowering plant...", rating: 4.9, counting: 45),
        PlantModel(id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,image: "Showy Spindletree Euonymus japonicus", name: "Showy Spindletree Euonymus japonicus", type: "Outdoor Plant", typePlant: "outdoorPlant",price: 7.00, description: "Aromatic flowering plant...", rating: 4.9, counting: 45),
        PlantModel(id: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!,image: "Showy Spindletree Euonymus japonicus", name: "Showy Spindletree Euonymus japonicus", type: "Outdoor Plant", typePlant: "outdoorPlant",price: 7.00, description: "Aromatic flowering plant...", rating: 4.9, counting: 45),
        PlantModel(id: UUID(uuidString: "00000000-0000-0000-0000-000000000005")!,image: "Showy Spindletree Euonymus japonicus", name: "Showy Spindletree Euonymus japonicus", type: "Outdoor Plant", typePlant: "outdoorPlant",price: 7.00, description: "Aromatic flowering plant...", rating: 4.9, counting: 45),
    ]

    static let aquaticPlants: [PlantModel] = [
        PlantModel(id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,image: "Maianthemum", name: "Maianthemum", type: "Aquatic Plant", typePlant: "aquaticPlant",price: 9.00, description: "Sacred aquatic flower...", rating: 4.9, counting: 22),
        PlantModel(id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,image: "Maianthemum", name: "Maianthemum", type: "Aquatic Plant", typePlant: "aquaticPlant",price: 9.00, description: "Sacred aquatic flower...", rating: 4.9, counting: 22),
        PlantModel(id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,image: "Maianthemum", name: "Maianthemum", type: "Aquatic Plant", typePlant: "aquaticPlant",price: 9.00, description: "Sacred aquatic flower...", rating: 4.9, counting: 22),
        PlantModel(id: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!,image: "Maianthemum", name: "Maianthemum", type: "Aquatic Plant", typePlant: "aquaticPlant",price: 9.00, description: "Sacred aquatic flower...", rating: 4.9, counting: 22),
        PlantModel(id: UUID(uuidString: "00000000-0000-0000-0000-000000000005")!,image: "Maianthemum", name: "Maianthemum", type: "Aquatic Plant", typePlant: "aquaticPlant",price: 9.00, description: "Sacred aquatic flower...", rating: 4.9, counting: 22),
        PlantModel(id: UUID(uuidString: "00000000-0000-0000-0000-000000000006")!,image: "Maianthemum", name: "Maianthemum", type: "Aquatic Plant", typePlant: "aquaticPlant",price: 9.00, description: "Sacred aquatic flower...", rating: 4.9, counting: 22),
    ]

    static let bigTrees: [PlantModel] = [
        PlantModel(id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!, image: "Mango", name: "Mango", type: "Big Tree", typePlant: "bigTree", price: 45.00, description: "Majestic deciduous tree...", rating: 5.0, counting: 12),
        PlantModel(id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!, image: "Mango", name: "Mango", type: "Big Tree", typePlant: "bigTree", price: 45.00, description: "Majestic deciduous tree...", rating: 5.0, counting: 12),
        PlantModel(id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!, image: "Mango", name: "Mango", type: "Big Tree", typePlant: "bigTree", price: 45.00, description: "Majestic deciduous tree...", rating: 5.0, counting: 12),
        PlantModel(id: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!, image: "Mango", name: "Mango", type: "Big Tree", typePlant: "bigTree", price: 45.00, description: "Majestic deciduous tree...", rating: 5.0, counting: 12),
        PlantModel(id: UUID(uuidString: "00000000-0000-0000-0000-000000000005")!, image: "Mango", name: "Mango", type: "Big Tree", typePlant: "bigTree", price: 45.00, description: "Majestic deciduous tree...", rating: 5.0, counting: 12),
        PlantModel(id: UUID(uuidString: "00000000-0000-0000-0000-000000000006")!, image: "Mango", name: "Mango", type: "Big Tree", typePlant: "bigTree", price: 45.00, description: "Majestic deciduous tree...", rating: 5.0, counting: 12),
    ]
    static let popularPlants: [PlantModel] = [
        indoorPlants[0],
        outdoorPlants[0],
        bigTrees[0],
        aquaticPlants[0]
    ]
}

