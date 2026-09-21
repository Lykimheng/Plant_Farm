//
//  AddMyPlantView.swift
//  PP
//
//  Created by Ly Kimheng on 9/6/26.
//

import SwiftUI

struct AddMyPlantView: View {
    @EnvironmentObject var myPlants: MyPlantsModel
    @EnvironmentObject var user: UserModel
    @EnvironmentObject var catalog: PlantsModel
    @Environment(\.dismiss) private var dismiss

    @State private var species = ""
    @State private var selectedCare: MyPlantModel.CareLevel = .easy
    @State private var nextWatering = "Next in 3 days"
    @State private var sunlight = "Partial Sunlight"
    @State private var selectedPlant: PlantModel?
    @State private var isSaving = false

    private var availablePlants: [PlantModel] {
        var seen = Set<String>()
        return catalog.plants.filter { seen.insert($0.name).inserted }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Plant Info") {
                    Picker("Plant name", selection: $selectedPlant) {
                        Text("Select a plant").tag(nil as PlantModel?)
                        ForEach(availablePlants) { plant in
                            Text(plant.name).tag(plant as PlantModel?)
                        }
                    }
                    TextField("Species", text: $species)
                }

                Section("Care Level") {
                    Picker("Care Level", selection: $selectedCare) {
                        Text("Easy Care").tag(MyPlantModel.CareLevel.easy)
                        Text("Moderate Care").tag(MyPlantModel.CareLevel.moderate)
                        Text("Expert Care").tag(MyPlantModel.CareLevel.expert)
                    }
                    .pickerStyle(.segmented)
                }

                Section("Schedule") {
                    TextField("Next watering", text: $nextWatering)
                    TextField("Sunlight needs", text: $sunlight)
                }

                if let selectedPlant {
                    Section("Image Preview") {
                        RemoteImage(urlString: selectedPlant.image)
                            .scaledToFit()
                            .frame(height: 120)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle("Add Plant")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                if catalog.plants.isEmpty {
                    await catalog.fetchPlants()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .disabled(isSaving)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Button("Save") {
                            guard let selectedPlant else { return }
                            isSaving = true
                            Task {
                                await myPlants.addPlant(
                                    MyPlantModel(
                                        image: selectedPlant.image,
                                        name: selectedPlant.name,
                                        species: species,
                                        careLevel: selectedCare,
                                        nextWatering: nextWatering,
                                        sunlight: sunlight
                                    ),
                                    userId: user.id
                                )
                                dismiss()
                            }
                        }
                        .disabled(selectedPlant == nil)
                    }
                }
            }
        }
    }
}
