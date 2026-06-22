//
//  CartModel.swift
//  PP
//
//  Created by Ly Kimheng on 29/5/26.
//

import SwiftUI
import Combine

class CartModel: ObservableObject {
    @Published var items: [CartItem] = []
    var toastCenter: ToastCenter?

    // Add to cart
    func addItem(plant: PlantModel, quantity: Int = 1) {
        if let index = items.firstIndex(where: { $0.plant.id == plant.id }) {
            // already in cart -> increase quantity
            items[index].quantity += quantity
        } else {
            // new item -> add to cart
            items.append(CartItem(plant: plant, quantity: 1))
        }
        toastCenter?.show("\(plant.name) added to cart!")
    }

    // Remove from cart
    func removeItem(plant: PlantModel) {
        items.removeAll { $0.plant.id == plant.id }
    }
    
    // Increase quantity
    func increase(plant: PlantModel) {
        if let index = items.firstIndex(where: { $0.plant.id == plant.id }) {
            items[index].quantity += 1
        }
    }
    
    // Decrease quantity
    func decrease(plant: PlantModel) {
        if let index = items.firstIndex(where: { $0.plant.id == plant.id }) {
            if items[index].quantity > 1 {
                items[index].quantity -= 1
            } else {
                removeItem(plant: plant)   // remove if quantity hits 0
            }
        }
    }
    func clearCart() {
        items.removeAll()
    }
    
    // Total price
    var totalPrice: Double {
        items.reduce(0) { $0 + ($1.plant.price * Double($1.quantity)) }
    }
    
    // Total item count (for cart badge)
    var totalCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }
}

// MARK: - CartItem
struct CartItem: Identifiable {
    let id = UUID()
    let plant: PlantModel
    var quantity: Int
}
