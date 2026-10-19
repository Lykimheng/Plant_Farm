//
//  ScanViewModel.swift
//  PP
//
//  Created by Ly Kimheng on 16/9/26.
//

import SwiftUI
import Combine

@MainActor
final class ScanViewModel: ObservableObject {
    @Published private(set) var image: UIImage?
    @Published private(set) var predictions: [PlantPrediction] = []
    @Published private(set) var health: [HealthPrediction] = []
    @Published private(set) var isIdentifying = false
    @Published private(set) var errorMessage: LocalizedStringResource?
    @Published var isShowingResult = false

    weak var history: ScanHistoryStore?

    private let speciesClassifier: ImageClassifier
    private let healthClassifier: ImageClassifier

    init(species: ImageClassifier = .species, health: ImageClassifier = .health) {
        speciesClassifier = species
        healthClassifier = health
    }

    convenience init(record: ScanRecord, image: UIImage?) {
        self.init()
        self.image = image
        predictions = record.predictions
        health = record.healthPredictions
    }

    var bestMatch: PlantPrediction? { predictions.first }
    var healthVerdict: HealthPrediction? { health.first }
    func identify(_ image: UIImage) async {
        self.image = image
        predictions = []
        health = []
        errorMessage = nil
        isIdentifying = true
        isShowingResult = true
        defer { isIdentifying = false }

        // Both models read the same photo; run them side by side.
        let healthTask = Task { try await healthClassifier.classify(image) }

        do {
            predictions = try await speciesClassifier.classify(image).compactMap(PlantPrediction.init)
        } catch {
            AppLog.warning("Plant identification failed: \(error.localizedDescription)")
            let friendly = error as? ImageClassifierError ?? .inferenceFailed
            errorMessage = friendly.message
        }

        do {
            health = try await healthTask.value.compactMap(HealthPrediction.init)
        } catch {
            AppLog.warning("Health check unavailable: \(error.localizedDescription)")
        }

        history?.add(image: image, predictions: predictions, health: health)
    }

    func retry() async {
        guard let image else { return }
        await identify(image)
    }
}
