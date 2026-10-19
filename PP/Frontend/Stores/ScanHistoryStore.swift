//
//  ScanHistoryStore.swift
//  PP
//

import SwiftUI
import Combine

nonisolated struct ScanRecord: Identifiable, Codable, Hashable, Sendable {
    struct Guess: Codable, Hashable, Sendable {
        let label: String
        let confidence: Double
    }

    let id: UUID
    let date: Date
    let species: [Guess]
    let health: [Guess]

    var imageFileName: String { "\(id.uuidString).jpg" }

    var predictions: [PlantPrediction] {
        species.compactMap { PlantPrediction(Classification(label: $0.label, confidence: $0.confidence)) }
    }

    var healthPredictions: [HealthPrediction] {
        health.compactMap { HealthPrediction(Classification(label: $0.label, confidence: $0.confidence)) }
    }
}

// Kept on the device, so guests have a history too
@MainActor
final class ScanHistoryStore: ObservableObject {
    @Published private(set) var records: [ScanRecord] = []

    static let limit = 50

    private let folder: URL
    private let images = NSCache<NSString, UIImage>()

    init(folder: URL = .applicationSupportDirectory.appending(path: "ScanHistory", directoryHint: .isDirectory)) {
        self.folder = folder
        load()
    }

    var isEmpty: Bool { records.isEmpty }

    func add(image: UIImage, predictions: [PlantPrediction], health: [HealthPrediction]) {
        guard !predictions.isEmpty else { return }

        let record = ScanRecord(
            id: UUID(),
            date: .now,
            species: predictions.prefix(3).map { .init(label: $0.species.rawValue, confidence: $0.confidence) },
            health: health.prefix(3).map { .init(label: $0.symptom.rawValue, confidence: $0.confidence) }
        )

        let photo = image.resized(maxDimension: 800)
        do {
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            if let data = photo.jpegData(compressionQuality: 0.75) {
                try data.write(to: url(for: record), options: .atomic)
                images.setObject(photo, forKey: record.imageFileName as NSString)
            }
        } catch {
            AppLog.warning("Couldn't save the scan photo: \(error.localizedDescription)")
        }

        records.insert(record, at: 0)
        if records.count > Self.limit {
            records[Self.limit...].forEach(deleteImage)
            records.removeLast(records.count - Self.limit)
        }
        save()
    }

    func remove(_ record: ScanRecord) {
        records.removeAll { $0.id == record.id }
        deleteImage(record)
        save()
    }

    func clear() {
        records.forEach(deleteImage)
        records.removeAll()
        save()
    }

    func image(for record: ScanRecord) -> UIImage? {
        let key = record.imageFileName as NSString
        if let cached = images.object(forKey: key) { return cached }
        guard let image = UIImage(contentsOfFile: url(for: record).path) else { return nil }
        images.setObject(image, forKey: key)
        return image
    }

    // MARK: - Storage

    private var indexURL: URL { folder.appending(path: "history.json") }

    private func url(for record: ScanRecord) -> URL {
        folder.appending(path: record.imageFileName)
    }

    private func load() {
        guard let data = try? Data(contentsOf: indexURL) else { return }
        records = (try? JSONDecoder().decode([ScanRecord].self, from: data)) ?? []
    }

    private func save() {
        do {
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            try JSONEncoder().encode(records).write(to: indexURL, options: .atomic)
        } catch {
            AppLog.warning("Couldn't save scan history: \(error.localizedDescription)")
        }
    }

    private func deleteImage(_ record: ScanRecord) {
        images.removeObject(forKey: record.imageFileName as NSString)
        try? FileManager.default.removeItem(at: url(for: record))
    }
}
