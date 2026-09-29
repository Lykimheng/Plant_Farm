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
                    NavigationLink {
                        CatalogPlantPicker(plants: availablePlants, selection: $selectedPlant)
                    } label: {
                        LabeledContent("From the catalog") {
                            if let selectedPlant {
                                Text(selectedPlant.name)
                            } else {
                                Text("Choose a plant")
                            }
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
                            Text(interval.title).tag(interval)
                        }
                    }

                    Picker("Sunlight", selection: $sunlight) {
                        ForEach(SunlightNeed.allCases) { need in
                            Text(need.title).tag(need)
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
                                Text("\(Text(wateringInterval.title)) · \(Text(sunlight.title))")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Theme.textSecondary)
                            }
                        }
                    }
                }

                if myPlants.errorMessage != nil {
                    Section {
                        InlineError(message: myPlants.errorMessage)
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

// MARK: - Plant picker

private struct CatalogPlantPicker: View {
    let plants: [PlantModel]
    @Binding var selection: PlantModel?

    @Environment(\.dismiss) private var dismiss
    @State private var query = ""

    private var results: [PlantModel] {
        let term = query.trimmed
        guard !term.isEmpty else { return plants }
        return plants.filter {
            $0.name.localizedCaseInsensitiveContains(term) || $0.type.localizedCaseInsensitiveContains(term)
        }
    }

    var body: some View {
        List(results) { plant in
            Button {
                selection = plant
                dismiss()
            } label: {
                row(for: plant)
            }
            .foregroundStyle(Theme.textPrimary)
        }
        .overlay {
            if results.isEmpty {
                ContentUnavailableView("No plants found", systemImage: Icons.search)
            }
        }
        .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search plants")
        .navigationTitle("Choose a plant")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func row(for plant: PlantModel) -> some View {
        HStack(spacing: Theme.Spacing.md) {
            RemoteImage(urlString: plant.image)
                .scaledToFill()
                .frame(width: 40, height: 40)
                .clipped()
                .background(Theme.surfaceAlt)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.sm, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(plant.name)
                    .font(.system(size: 15))
                Text(plant.type)
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.textSecondary)
            }

            Spacer(minLength: 0)

            if plant.id == selection?.id {
                Image(systemName: Icons.checkmark)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.brand)
            }
        }
        .contentShape(Rectangle())
    }
}

// MARK: - Options

enum WateringInterval: String, CaseIterable, Identifiable {
    case everyOtherDay, twiceWeekly, weekly, fortnightly, monthly

    var id: String { rawValue }

    var title: LocalizedStringResource {
        switch self {
        case .everyOtherDay: return "Every other day"
        case .twiceWeekly:   return "Twice a week"
        case .weekly:        return "Weekly"
        case .fortnightly:   return "Every two weeks"
        case .monthly:       return "Monthly"
        }
    }
    var label: String { title.string(in: Locale(identifier: "en")) }
}

enum SunlightNeed: String, CaseIterable, Identifiable {
    case full, partial, shade, indirect

    var id: String { rawValue }

    var title: LocalizedStringResource {
        switch self {
        case .full:     return "Full sun"
        case .partial:  return "Partial sun"
        case .shade:    return "Shade"
        case .indirect: return "Bright indirect"
        }
    }

    var label: String { title.string(in: Locale(identifier: "en")) }
}

#Preview {
    AddMyPlantView()
        .environmentObject(MyPlantsStore())
        .environmentObject(UserStore())
        .environmentObject(PlantsStore())
}
