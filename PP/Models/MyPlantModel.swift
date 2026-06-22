//
//  MyPlantModel.swift
//  PP
//
//  Created by Ly Kimheng on 9/6/26.
//

import SwiftUI
import Combine

struct MyPlantModel: Identifiable, Codable {
    let id: UUID
    var apiId: Int = 0
    let image: String
    let name: String
    let species: String
    let careLevel: CareLevel
    let nextWatering: String
    let sunlight: String
    let addedDate: Date
    
    init(apiId: Int = 0, image: String, name: String, species: String,
         careLevel: CareLevel, nextWatering: String, sunlight: String) {
        self.id = UUID()
        self.apiId = apiId
        self.image = image
        self.name = name
        self.species = species
        self.careLevel = careLevel
        self.nextWatering = nextWatering
        self.sunlight = sunlight
        self.addedDate = Date()
    }
    
    enum CareLevel: String, Codable {
        case easy = "easy"
        case moderate = "moderate"
        case expert = "expert"
        
        var displayName: String {
            switch self {
            case .easy:     return "Easy Care"
            case .moderate: return "Moderate Care"
            case .expert:   return "Expert Care"
            }
        }
        
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
