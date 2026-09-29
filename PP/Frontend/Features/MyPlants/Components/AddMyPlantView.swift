//
//  AddMyPlantView.swift
//  PP
//
//  Created by Ly Kimheng on 9/6/26.
//

import SwiftUI

struct AddMyPlantView: View {
    @EnvironmentObject private var myPlants: MyPlantsStore
    @EnvironmentObject private var user: UserStore
    @EnvironmentObject private var catalog: PlantsStore
    @Environment(\.dismiss) private var dismiss

    @State private var selectedPlant: PlantModel?
    @State private var species = ""
    @State private var careLevel: MyPlantModel.CareLevel = .easy
    @State private var wateringInterval = WateringInterval.weekly
    @State private var sunlight = SunlightNeed.partial
    @State private var isSaving = false
    private var availablePlants: [PlantModel] {
        var seen = Set<String>()
        return catalog.plants.filter { seen.insert($0.name).inserted }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Plant") {
                    Picker("From the catalog", selection: $selectedPlant) {
                        Text("Choose a plant").tag(nil as PlantModel?)
                        ForEach(availablePlants) { plant in
                            Text(plant.name).tag(plant as PlantModel?)
                        }
                    }

                    TextField("Species (optional)", text: $species)
                        .autocorrectionDisabled()
                }

                Section("Care") {
                    Picker("Care level", selection: $careLevel) {
                        ForEach(MyPlantModel.CareLevel.allCases) { level in
                            Text(level.shortName).tag(level)
                        }
                    }
                    .pickerStyle(.segmented)

                    Picker("Watering", selection: $wateringInterval) {
                        ForEach(WateringInterval.allCases) { interval in
                            Text(interval.label).tag(interval)
                        }
                    }

                    Picker("Sunlight", selection: $sunlight) {
                        ForEach(SunlightNeed.allCases) { need in
                            Text(need.label).tag(need)
                        }
                    }
                }

                if let selectedPlant {
                    Section("Preview") {
                        HStack(spacing: Theme.Spacing.md) {
                            RemoteImage(urlString: selectedPlant.image)
                                .scaledToFill()
                                .frame(width: 64, height: 64)
                                .clipped()
                                .background(Theme.surfaceAlt)
                                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.sm, style: .continuous))

                            VStack(alignment: .leading, spacing: 3) {
                                Text(selectedPlant.name)
                                    .font(.system(size: 15, weight: .semibold))
                                Text("\(wateringInterval.label) · \(sunlight.label)")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Theme.textSecondary)
                            }
                        }
                    }
                }

                if !myPlants.errorMessage.isEmpty {
                    Section {
                        Label(myPlants.errorMessage, systemImage: "exclamationmark.triangle")
                            .font(.system(size: 12.5))
                            .foregroundStyle(Theme.danger)
                    }
                }
            }
            .navigationTitle("Add a plant")
            .navigationBarTitleDisplayMode(.inline)
            .task { await catalog.loadIfNeeded() }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .disabled(isSaving)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Button("Save", action: save)
                            .fontWeight(.semibold)
                            .disabled(selectedPlant == nil)
                    }
                }
            }
        }
    }

    private func save() {
        guard let selectedPlant else { return }
        isSaving = true

        Task {
            let added = await myPlants.add(
                MyPlantModel(
                    image: selectedPlant.image,
                    name: selectedPlant.name,
                    species: species.trimmed,
                    careLevel: careLevel,
                    nextWatering: wateringInterval.label,
                    sunlight: sunlight.label
                ),
                userId: user.id
            )
            isSaving = false
            if added { dismiss() }
        }
    }
}

// MARK: - Options

enum WateringInterval: String, CaseIterable, Identifiable {
    case everyOtherDay, twiceWeekly, weekly, fortnightly, monthly

    var id: String { rawValue }

    var label: String {
        switch self {
        case .everyOtherDay: return "Every other day"
        case .twiceWeekly:   return "Twice a week"
        case .weekly:        return "Weekly"
        case .fortnightly:   return "Every two weeks"
        case .monthly:       return "Monthly"
        }
    }
}

enum SunlightNeed: String, CaseIterable, Identifiable {
    case full, partial, shade, indirect

    var id: String { rawValue }

    var label: String {
        switch self {
        case .full:     return "Full sun"
        case .partial:  return "Partial sun"
        case .shade:    return "Shade"
        case .indirect: return "Bright indirect"
        }
    }
}

#Preview {
    AddMyPlantView()
        .environmentObject(MyPlantsStore())
        .environmentObject(UserStore())
        .environmentObject(PlantsStore())
}
