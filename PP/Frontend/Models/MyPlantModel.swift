//
//  MyPlantModel.swift
//  PP
//
//  Created by Ly Kimheng on 9/6/26.
//

import SwiftUI

nonisolated struct MyPlantModel: Identifiable, Hashable {
    let id: UUID
    var apiId: Int
    let image: String
    let name: String
    let species: String
    let careLevel: CareLevel
    let nextWatering: String
    let sunlight: String
    let addedDate: Date

    init(
        apiId: Int = 0,
        image: String,
        name: String,
        species: String,
        careLevel: CareLevel,
        nextWatering: String,
        sunlight: String,
        addedDate: Date = Date()
    ) {
        self.id = UUID()
        self.apiId = apiId
        self.image = image
        self.name = name
        self.species = species
        self.careLevel = careLevel
        self.nextWatering = nextWatering
        self.sunlight = sunlight
        self.addedDate = addedDate
    }

    enum CareLevel: String, CaseIterable, Identifiable {
        case easy, moderate, expert

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .easy:     return "Easy care"
            case .moderate: return "Moderate care"
            case .expert:   return "Expert care"
            }
        }

        /// For tight spots like a segmented control, where "care" is already implied.
        var shortName: String {
            switch self {
            case .easy:     return "Easy"
            case .moderate: return "Moderate"
            case .expert:   return "Expert"
            }
        }

        var color: Color {
            switch self {
            case .easy:     return Theme.success
            case .moderate: return Theme.brand
            case .expert:   return Theme.warning
            }
        }

        var icon: String {
            switch self {
            case .easy:     return "bolt.fill"
            case .moderate: return Icons.myPlants
            case .expert:   return "flame.fill"
            }
        }
    }
}
