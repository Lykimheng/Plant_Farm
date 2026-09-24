//
//  MyPlantsStore.swift
//  PP
//
//  Created by Ly Kimheng on 12/8/26.
//

import SwiftUI
import Combine

@MainActor
final class MyPlantsStore: ObservableObject {
    @Published private(set) var plants: [MyPlantModel] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""

    private let client: APIClient
    private var loadedForUser: Int?

    init(client: APIClient = .shared) {
        self.client = client
    }

    var isEmpty: Bool { plants.isEmpty }

    var careLevelText: String {
        switch plants.count {
        case 0:      return "Lvl 1"
        case 1...3:  return "Lvl 2"
        case 4...7:  return "Lvl 3"
        case 8...12: return "Lvl 4"
        default:     return "Lvl 5"
        }
    }

    func clearLocally() {
        plants.removeAll()
        loadedForUser = nil
    }

    // MARK: - Server

    func loadIfNeeded(userId: Int) async {
        guard loadedForUser != userId else { return }
        await load(userId: userId)
    }

    func load(userId: Int) async {
        guard userId != 0 else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let response: MyPlantsResponse = try await client.get(
                API.Path.myPlants,
                query: ["user_id": String(userId)]
            )
            plants = response.plants.map(\.myPlant)
            loadedForUser = userId
            errorMessage = ""
        } catch {
            errorMessage = error.userMessage
            AppLog.network("load my plants", error)
        }
    }

    @discardableResult
    func add(_ plant: MyPlantModel, userId: Int) async -> Bool {
        do {
            let response: AddMyPlantResponse = try await client.send(
                API.Path.myPlants,
                method: .post,
                body: AddMyPlantRequest(
                    userId: userId,
                    image: plant.image,
                    name: plant.name,
                    species: plant.species,
                    careLevel: plant.careLevel.rawValue,
                    nextWatering: plant.nextWatering,
                    sunlight: plant.sunlight
                )
            )

            var stored = plant
            stored.apiId = response.plantId ?? 0
            plants.insert(stored, at: 0)
            errorMessage = ""
            return true
        } catch {
            errorMessage = error.userMessage
            AppLog.network("add my plant", error)
            return false
        }
    }

    func remove(_ plant: MyPlantModel, userId: Int) async {
        guard let index = plants.firstIndex(where: { $0.id == plant.id }) else { return }

        let removed = plants.remove(at: index)

        do {
            let _: StatusResponse = try await client.send(
                API.Path.myPlants,
                method: .delete,
                body: RemoveMyPlantRequest(plantId: plant.apiId, userId: userId)
            )
        } catch {
            plants.insert(removed, at: min(index, plants.count))
            errorMessage = error.userMessage
            AppLog.network("remove my plant", error)
        }
    }
}
