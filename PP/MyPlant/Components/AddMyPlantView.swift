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
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var species = ""
    @State private var selectedCare: MyPlantModel.CareLevel = .easy
    @State private var nextWatering = "Next in 3 days"
    @State private var sunlight = "Partial Sunlight"
    @State private var image = "Cactus"
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Plant Info") {
                    TextField("Plant name", text: $name)
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

                Section("Image") {
                    TextField("Image name from assets", text: $image)
                }
            }
            .navigationTitle("Add Plant")
            .navigationBarTitleDisplayMode(.inline)
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
                            isSaving = true
                            Task {
                                await myPlants.addPlant(
                                    MyPlantModel(
                                        image: image,
                                        name: name,
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
                        .disabled(name.isEmpty)
                    }
                }
            }
        }
    }
}
