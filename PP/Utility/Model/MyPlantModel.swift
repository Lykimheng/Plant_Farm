//
//  MyPlantModel.swift
//  PP
//
//  Created by Ly Kimheng on 9/6/26.
//

import SwiftUI
import Combine

struct MyPlantModel: Identifiable {
    let id = UUID()
    let image: String
    let name: String
    let species: String
    let careLevel: CareLevel
    let nextWatering: String
    let sunlight: String
    let addedDate: Date = Date()

    enum CareLevel: String {
        case easy = "Easy Care"
        case moderate = "Moderate Care"
        case expert = "Expert Care"

        var color: Color {
            switch self {
            case .easy:     return .green
            case .moderate: return Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255)
            case .expert:   return .orange
            }
        }

        var icon: String {
            switch self {
            case .easy:     return "bolt.fill"
            case .moderate: return "leaf.fill"
            case .expert:   return "flame.fill"
            }
        }
    }
}

class MyPlantsModel: ObservableObject {
    @Published var plants: [MyPlantModel] = []

    func addPlant(_ plant: MyPlantModel) {
        plants.insert(plant, at: 0)
    }

    func removePlant(_ plant: MyPlantModel) {
        plants.removeAll { $0.id == plant.id }
    }
}
