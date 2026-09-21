//
//  MyPlantsModel.swift
//  PP
//
//  Created by Ly Kimheng on 17/6/26.
//

import SwiftUI
import Combine

class MyPlantsModel: ObservableObject {
    @Published var plants: [MyPlantModel] = []
    @Published var isLoading = false

    var careLevelText: String {
        switch plants.count {
        case 0:        return "Lvl 1"
        case 1...3:    return "Lvl 2"
        case 4...7:    return "Lvl 3"
        case 8...12:   return "Lvl 4"
        default:       return "Lvl 5"
        }
    }

    // MARK: - Fetch from API
    func fetchPlants(userId: Int) async {
        await MainActor.run { isLoading = true }

        guard let url = URL(string: "\(APIService.shared.baseURL)/my_plants.php?user_id=\(userId)") else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            print("fetchPlants raw response: \(String(data: data, encoding: .utf8) ?? "nil")")
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let plantsArray = json["plants"] as? [[String: Any]] {
                let fetched = plantsArray.compactMap { dict -> MyPlantModel? in
                    guard let name = dict["name"] as? String,
                          let species = dict["species"] as? String,
                          let image = dict["image"] as? String,
                          let careLevelStr = dict["care_level"] as? String,
                          let nextWatering = dict["next_watering"] as? String,
                          let sunlight = dict["sunlight"] as? String,
                          let apiId = dict["id"] as? Int else { return nil }

                    return MyPlantModel(
                        apiId: apiId,
                        image: image,
                        name: name,
                        species: species,
                        careLevel: MyPlantModel.CareLevel(rawValue: careLevelStr) ?? .easy,
                        nextWatering: nextWatering,
                        sunlight: sunlight
                    )
                }
                await MainActor.run {
                    self.plants = fetched
                    self.isLoading = false
                }
            }
        } catch {
            await MainActor.run { isLoading = false }
            print("Fetch plants error: \(error)")
        }
    }

    // MARK: - Add to API
    func addPlant(_ plant: MyPlantModel, userId: Int) async {
        let body: [String: Any] = [
            "user_id":      userId,
            "image":        plant.image,
            "name":         plant.name,
            "species":      plant.species,
            "care_level":   plant.careLevel.rawValue,
            "next_watering": plant.nextWatering,
            "sunlight":     plant.sunlight
        ]

        guard let url = URL(string: "\(APIService.shared.baseURL)/my_plants.php"),
              let jsonData = try? JSONSerialization.data(withJSONObject: body) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            print("addPlant raw response: \(String(data: data, encoding: .utf8) ?? "nil")")
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let success = json["success"] as? Bool, success,
               let plantId = json["plant_id"] as? Int {
                var newPlant = plant
                newPlant.apiId = plantId         // <- save DB id
                await MainActor.run {
                    plants.insert(newPlant, at: 0)
                }
            }
        } catch {
            print("Add plant error: \(error)")
        }
    }

    // MARK: - Remove from API
    func removePlant(_ plant: MyPlantModel, userId: Int) async {
        let body: [String: Any] = [
            "plant_id": plant.apiId,
            "user_id":  userId
        ]

        guard let url = URL(string: "\(APIService.shared.baseURL)/my_plants.php"),
              let jsonData = try? JSONSerialization.data(withJSONObject: body) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        do {
            let (_, _) = try await URLSession.shared.data(for: request)
            await MainActor.run {
                plants.removeAll { $0.id == plant.id }
            }
        } catch {
            print("Remove plant error: \(error)")
        }
    }
}
