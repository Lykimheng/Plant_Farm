//
//  WishlistStore.swift
//  PP
//
//  Created by Ly Kimheng on 12/8/26.
//

import SwiftUI
import Combine

@MainActor
final class WishlistStore: ObservableObject {
    @Published private(set) var items: [PlantModel] = []

    var isEmpty: Bool { items.isEmpty }

    func contains(_ plant: PlantModel) -> Bool {
        items.contains { $0.id == plant.id }
    }

    func toggle(_ plant: PlantModel) {
        if let index = items.firstIndex(where: { $0.id == plant.id }) {
            items.remove(at: index)
        } else {
            items.append(plant)
        }
    }

    func remove(_ plant: PlantModel) {
        items.removeAll { $0.id == plant.id }
    }

    func clear() {
        items.removeAll()
    }
}
