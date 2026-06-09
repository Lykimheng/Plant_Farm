//
//  FavoriteModel.swift
//  PP
//
//  Created by Ly Kimheng on 8/6/26.
//

import SwiftUI
import Combine

class WishlistModel: ObservableObject {
    @Published var items: [PlantModel] = []
    
    func addItem(plant: PlantModel) {
        if !items.contains(where: { $0.id == plant.id }) {
            items.append(plant)
        }
    }
    
    func removeItem(plant: PlantModel) {
        items.removeAll { $0.id == plant.id }
    }
    
    func toggleItem(plant: PlantModel) {
        if isWishlisted(plant) {
            removeItem(plant: plant)
        } else {
            addItem(plant: plant)
        }
    }
    
    func isWishlisted(_ plant: PlantModel) -> Bool {
        items.contains(where: { $0.id == plant.id })
    }
    
    func clearAll() {
        items.removeAll()
    }
}
