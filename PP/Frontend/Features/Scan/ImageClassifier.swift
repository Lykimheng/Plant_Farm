//
//  ImageClassifier.swift
//  PP
//
//  Created by Ly Kimheng on 16/9/26.
//

import CoreML
import UIKit
import Vision

nonisolated struct Classification: Hashable, Sendable {
    let label: String
    let confidence: Double
}

nonisolated enum ImageClassifierError: LocalizedError {
    case modelMissing(String)
    case unreadableImage
    case inferenceFailed
    var message: LocalizedStringResource {
        switch self {
        case .modelMissing(let name):
            return "\(name) isn't included in this build."
        case .unreadableImage:
            return "That photo couldn't be read. Try another one."
        case .inferenceFailed:
            #if targetEnvironment(simulator)
            return "Plant recognition can't run in the iOS Simulator. Run the app on a phone to try it."
            #else
            return "Something went wrong while looking at the photo. Please try again."
            #endif
        }
    }

    var errorDescription: String? { String(localized: message) }
}
actor ImageClassifier {
    static let species = ImageClassifier(modelName: "PlantClassifier")
    static let health = ImageClassifier(modelName: "PlantHealthClassifier")

    private let modelName: String
    private var request: CoreMLRequest?
    private var computeUnits: MLComputeUnits = .all

    init(modelName: String) {
        self.modelName = modelName
    }
    
    func classify(_ image: UIImage) async throws -> [Classification] {
        guard let cgImage = Self.upright(image, maxDimension: 720) else {
            throw ImageClassifierError.unreadableImage
        }

        let observations: [any VisionObservation]
        do {
            observations = try await loadedRequest().perform(on: cgImage, orientation: .up)
        } catch let error as ImageClassifierError {
            throw error
        } catch where computeUnits != .cpuOnly {
            AppLog.warning("\(modelName) failed on \(computeUnits); retrying on CPU: \(error.localizedDescription)")
            computeUnits = .cpuOnly
            request = nil
            observations = try await loadedRequest().perform(on: cgImage, orientation: .up)
        }

        return observations
            .compactMap { $0 as? ClassificationObservation }
            .map { Classification(label: $0.identifier, confidence: Double($0.confidence)) }
            .sorted { $0.confidence > $1.confidence }
    }

    private func loadedRequest() async throws -> CoreMLRequest {
        if let request { return request }

        guard let url = Bundle.main.url(forResource: modelName, withExtension: "mlmodelc") else {
            throw ImageClassifierError.modelMissing(modelName)
        }

        let configuration = MLModelConfiguration()
        configuration.computeUnits = computeUnits
        let model = try await MLModel.load(contentsOf: url, configuration: configuration)
        var request = CoreMLRequest(model: try CoreMLModelContainer(model: model))
        request.cropAndScaleAction = .centerCrop   // how Create ML framed the training photos
        self.request = request
        return request
    }
    private static func upright(_ image: UIImage, maxDimension: CGFloat) -> CGImage? {
        let longestSide = max(image.size.width, image.size.height)
        guard longestSide > 0 else { return nil }

        let scale = min(1, maxDimension / longestSide)
        let target = CGSize(width: image.size.width * scale, height: image.size.height * scale)

        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        return UIGraphicsImageRenderer(size: target, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: target))
        }.cgImage
    }
}
