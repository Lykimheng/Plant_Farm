//
//  HomeViewModel.swift
//  PP
//
//  Created by Ly Kimheng on 17/6/26.
//

import SwiftUI
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var selectedCategory: PlantCategory = .all
    @Published private var expandedSections: Set<PlantCategory> = []
    @Published private var offersExpanded = false

    var isSearching: Bool { !searchText.isBlank }

    func isExpanded(_ category: PlantCategory) -> Bool {
        expandedSections.contains(category)
    }

    func toggle(_ category: PlantCategory) {
        withAnimation(.easeInOut(duration: 0.2)) {
            if expandedSections.contains(category) {
                expandedSections.remove(category)
            } else {
                expandedSections.insert(category)
            }
        }
    }

    var isOffersExpanded: Bool { offersExpanded }

    func toggleOffers() {
        withAnimation(.easeInOut(duration: 0.2)) { offersExpanded.toggle() }
    }

    func select(_ category: PlantCategory) {
        withAnimation(.easeInOut(duration: 0.2)) { selectedCategory = category }
    }

    func clearSearch() {
        searchText = ""
    }
}
