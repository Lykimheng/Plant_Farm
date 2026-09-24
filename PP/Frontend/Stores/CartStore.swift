//
//  CartStore.swift
//  PP
//
//  Created by Ly Kimheng on 12/8/26.
//

import SwiftUI
import Combine

struct CartItem: Identifiable, Hashable {
    var id: Int { plant.id }
    let plant: PlantModel
    var quantity: Int

    var lineTotal: Double { plant.price * Double(quantity) }
}

@MainActor
final class CartStore: ObservableObject {
    static let maximumPerLine = 20

    @Published private(set) var items: [CartItem] = []

    private weak var toastCenter: ToastCenter?

    func connect(toastCenter: ToastCenter) {
        self.toastCenter = toastCenter
    }

    // MARK: - Derived

    var isEmpty: Bool { items.isEmpty }

    var subtotal: Double { items.reduce(0) { $0 + $1.lineTotal } }

    /// Badge count on the Cart tab
    var totalCount: Int { items.reduce(0) { $0 + $1.quantity } }

    func quantity(of plant: PlantModel) -> Int {
        items.first { $0.plant.id == plant.id }?.quantity ?? 0
    }

    // MARK: - Mutations

    func add(_ plant: PlantModel, quantity: Int = 1) {
        if let index = items.firstIndex(where: { $0.plant.id == plant.id }) {
            items[index].quantity = min(items[index].quantity + quantity, Self.maximumPerLine)
        } else {
            items.append(CartItem(plant: plant, quantity: min(quantity, Self.maximumPerLine)))
        }
        toastCenter?.show("\(plant.name) added to cart")
    }

    func remove(_ plant: PlantModel) {
        items.removeAll { $0.plant.id == plant.id }
    }

    func increase(_ plant: PlantModel) {
        guard let index = items.firstIndex(where: { $0.plant.id == plant.id }),
              items[index].quantity < Self.maximumPerLine else { return }
        items[index].quantity += 1
    }

    func decrease(_ plant: PlantModel) {
        guard let index = items.firstIndex(where: { $0.plant.id == plant.id }) else { return }
        if items[index].quantity > 1 {
            items[index].quantity -= 1
        } else {
            items.remove(at: index)
        }
    }

    func clear() {
        items.removeAll()
    }
}
