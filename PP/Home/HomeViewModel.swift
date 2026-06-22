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

    func searchResults(in catalog: PlantsModel) -> [PlantModel] {
        guard !searchText.isEmpty else { return [] }
        return catalog.plants.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.type.localizedCaseInsensitiveContains(searchText)
        }
    }

    func filteredPlants(in catalog: PlantsModel) -> [PlantModel] {
        switch selectedCategory {
        case "Indoor":   return catalog.indoorPlants
        case "Outdoor":  return catalog.outdoorPlants
        case "Aquatic":  return catalog.aquaticPlants
        case "Big Tree": return catalog.bigTrees
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
