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
    @Published private(set) var errorMessage: String?
    @Published var isShowingResult = false

    private let speciesClassifier: ImageClassifier
    private let healthClassifier: ImageClassifier

    init(species: ImageClassifier = .species, health: ImageClassifier = .health) {
        speciesClassifier = species
        healthClassifier = health
    }

    var bestMatch: PlantPrediction? { predictions.first }
    var healthVerdict: HealthPrediction? { health.first }

    /// Opens the result sheet straight away and fills it in once the models
    /// answer, so the user sees their photo while the (sub-second) inference runs.
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
            // Core ML / Vision errors read like stack traces; keep those in the log.
            let friendly = error as? ImageClassifierError ?? .inferenceFailed
            errorMessage = friendly.errorDescription
        }

        do {
            health = try await healthTask.value.compactMap(HealthPrediction.init)
        } catch {
            AppLog.warning("Health check unavailable: \(error.localizedDescription)")
        }
    }

    func retry() async {
        guard let image else { return }
        await identify(image)
    }
}
