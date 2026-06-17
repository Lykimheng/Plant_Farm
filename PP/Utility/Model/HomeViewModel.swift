//
//  HomeViewModel.swift
//  PP
//
//  Created by Ly Kimheng on 17/6/26.
//

import SwiftUI
import Combine

class HomeViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var selectedCategory = "All"
    @Published var expandedSections: Set<String> = []

    // ← moved from HomeView
    var searchResults: [PlantModel] {
        let all = PlantData.indoorPlants + PlantData.outdoorPlants +
                  PlantData.aquaticPlants + PlantData.bigTrees
        if searchText.isEmpty { return [] }
        return all.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.type.localizedCaseInsensitiveContains(searchText)
        }
    }

    var filteredPlants: [PlantModel] {
        switch selectedCategory {
        case "Indoor":   return PlantData.indoorPlants
        case "Outdoor":  return PlantData.outdoorPlants
        case "Aquatic":  return PlantData.aquaticPlants
        case "Big Tree": return PlantData.bigTrees
        default:         return []
        }
    }

    func isExpanded(_ section: String) -> Bool {
        expandedSections.contains(section)
    }

    func toggleSection(_ section: String) {
        if expandedSections.contains(section) {
            expandedSections.remove(section)
        } else {
            expandedSections.insert(section)
        }
    }
}
