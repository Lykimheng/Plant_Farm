// TrainPlantClassifier.swift
// Trains the Plant Farm image classifiers without opening the Create ML app.
//
// Usage (in Terminal, from the app's repo root):
//   swift TrainPlantClassifier.swift /path/to/PlantData          -> PP/Frontend/ML/PlantClassifier.mlmodel
//   swift TrainPlantClassifier.swift /path/to/PlantSymptoms      -> PP/Frontend/ML/PlantHealthClassifier.mlmodel
//   swift TrainPlantClassifier.swift /path/to/Photos /out/Model.mlmodel   (explicit output)
//   swift TrainPlantClassifier.swift --flatten /path/to/PlantSymptoms
//       -> writes PlantSymptoms-for-CreateML next to it, with every photo moved up
//          into its class folder, because the Create ML app doesn't look inside
//          sub-folders. Drag that copy into the app's Image Classification template.
//
// The label is the top-level folder name. Photos may sit directly in that folder
// (monstera/xxx.jpg -> "monstera") or in sub-folders any depth down, which is how
// PlantSymptoms is organised (yellow_leaves/monstera/xxx.jpg -> "yellow_leaves").
// Photos loose in the root folder are labelled from their file name (monstera_01.jpg).
// Ignores annotations.json, README files and any .mlproj in the folder.
//
// What it does:
//   1. Holds back every 5th photo of each class and trains on the rest, so the
//      validation accuracy it prints is measured on photos the model never saw.
//   2. Retrains on every photo with the same settings and saves that as the final model.
// Run from the app's repo root and the model lands in PP/Frontend/ML, so Xcode
// picks it up on the next build; elsewhere it is saved next to the training folder.

import CreateML
import Foundation
import TabularData

let imageExtensions: Set<String> = ["jpg", "jpeg", "png", "heic"]
let fm = FileManager.default

let isFlattening = CommandLine.arguments.count >= 3 && CommandLine.arguments[1] == "--flatten"

guard CommandLine.arguments.count >= 2 else {
    print("Usage: swift TrainPlantClassifier.swift /path/to/PlantData [/path/to/PlantClassifier.mlmodel]")
    print("       swift TrainPlantClassifier.swift --flatten /path/to/PlantSymptoms")
    exit(1)
}

let dataURL = URL(fileURLWithPath: CommandLine.arguments[isFlattening ? 2 : 1], isDirectory: true)
let appModelFolder = URL(fileURLWithPath: "PP/Frontend/ML", isDirectory: true)

/// Which model file each dataset feeds. Any other folder becomes "<Folder>Classifier.mlmodel".
let modelNames = ["PlantData": "PlantClassifier", "PlantSymptoms": "PlantHealthClassifier"]
let modelFile = (modelNames[dataURL.lastPathComponent] ?? "\(dataURL.lastPathComponent)Classifier") + ".mlmodel"

let outputURL: URL
if CommandLine.arguments.count >= 3 {
    outputURL = URL(fileURLWithPath: CommandLine.arguments[2])
} else if FileManager.default.fileExists(atPath: appModelFolder.path) {
    outputURL = appModelFolder.appendingPathComponent(modelFile)
} else {
    outputURL = dataURL.deletingLastPathComponent().appendingPathComponent(modelFile)
}

func isDirectory(_ url: URL) -> Bool {
    (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
}

func contents(of folder: URL) -> [URL] {
    (try? fm.contentsOfDirectory(at: folder,
                                 includingPropertiesForKeys: [.isDirectoryKey],
                                 options: [.skipsHiddenFiles])) ?? []
}

func images(in folder: URL) -> [URL] {
    contents(of: folder)
        .filter { !isDirectory($0) && imageExtensions.contains($0.pathExtension.lowercased()) }
        .sorted { $0.lastPathComponent < $1.lastPathComponent }
}

/// Every photo under a class folder, however it is sub-divided (e.g. by plant).
func allImages(under folder: URL) -> [URL] {
    var found = images(in: folder)
    for sub in contents(of: folder) where isDirectory(sub) && sub.pathExtension.isEmpty {
        found.append(contentsOf: allImages(under: sub))
    }
    return found.sorted { $0.path < $1.path }
}

func label(fromFileName url: URL) -> String {
    url.deletingPathExtension().lastPathComponent
        .replacingOccurrences(of: #"_\d+$"#, with: "", options: .regularExpression)
}

// MARK: - --flatten: a copy the Create ML app can read

if isFlattening {
    let flatURL = dataURL.deletingLastPathComponent()
        .appendingPathComponent(dataURL.lastPathComponent + "-for-CreateML", isDirectory: true)
    try? fm.removeItem(at: flatURL)
    var copied = 0
    for classFolder in contents(of: dataURL) where isDirectory(classFolder) && classFolder.pathExtension.isEmpty {
        let photos = allImages(under: classFolder)
        guard !photos.isEmpty else {
            print("Skipping \(classFolder.lastPathComponent): no photos yet (the Create ML app rejects empty classes)")
            continue
        }
        let target = flatURL.appendingPathComponent(classFolder.lastPathComponent, isDirectory: true)
        try? fm.createDirectory(at: target, withIntermediateDirectories: true)
        for photo in photos {
            // Keep the plant name in the file name so nothing collides and the origin stays visible.
            let parent = photo.deletingLastPathComponent().lastPathComponent
            let name = parent == classFolder.lastPathComponent ? photo.lastPathComponent : "\(parent)_\(photo.lastPathComponent)"
            if (try? fm.copyItem(at: photo, to: target.appendingPathComponent(name))) != nil { copied += 1 }
        }
    }
    print("Copied \(copied) photos into \(flatURL.path)")
    print("In the Create ML app: File > New Project > Image Classification, then drag that folder onto Training Data.")
    print("It's a copy — keep adding photos to \(dataURL.lastPathComponent) and re-run --flatten when you want a fresh one.")
    exit(0)
}

var filesByLabel: [String: [URL]] = [:]

// 1. Photos sitting loose in the folder: label comes from the file name
for file in images(in: dataURL) {
    filesByLabel[label(fromFileName: file), default: []].append(file)
}

// 2. Photos inside class subfolders (any depth): label comes from the top-level folder name
var emptyClasses: [String] = []
for folder in contents(of: dataURL) where isDirectory(folder) {
    // Skip things like PlantImageClassifier.mlproj (they look like folders to macOS)
    guard folder.pathExtension.isEmpty else {
        print("Skipping \(folder.lastPathComponent)")
        continue
    }
    let files = allImages(under: folder)
    if files.isEmpty {
        emptyClasses.append(folder.lastPathComponent)
    } else {
        filesByLabel[folder.lastPathComponent, default: []].append(contentsOf: files)
    }
}

print("\nFound \(filesByLabel.count) classes in \(dataURL.lastPathComponent):")
for (label, files) in filesByLabel.sorted(by: { $0.key < $1.key }) {
    let synthetic = files.filter { $0.lastPathComponent.hasPrefix("sample_") }.count
    var notes: [String] = []
    if files.count < 10 { notes.append("fewer than 10 photos, add more") }
    if synthetic > 0 { notes.append("\(synthetic) synthetic sample_ photos — replace with real ones") }
    print("  \(label): \(files.count)" + (notes.isEmpty ? "" : "   <- " + notes.joined(separator: "; ")))
}
for label in emptyClasses.sorted() {
    print("  \(label): 0   <- no photos yet, left out of the model")
}

guard filesByLabel.count >= 2 else {
    print("\nNeed photos for at least 2 classes. Check that the folder path is correct.")
    exit(1)
}

// MARK: - Hold-out split (deterministic: every 5th photo of each class)

var trainingFiles: [String: [URL]] = [:]
var validationFiles: [String: [URL]] = [:]
for (label, files) in filesByLabel {
    for (index, file) in files.enumerated() {
        if files.count >= 5 && index % 5 == 4 {
            validationFiles[label, default: []].append(file)
        } else {
            trainingFiles[label, default: []].append(file)
        }
    }
}

// MARK: - Training settings

// Measured with two hold-out folds per dataset. scenePrint revision 2 beats
// revision 1 by ~15 points everywhere. Augmentation depends on the data:
//   PlantData (15 near-identical studio shots per plant): every augmentation
//     option lowered held-out accuracy by 5-9 points, so none is used.
//   PlantSymptoms (varied real photos, ~55 per symptom): crop+flip+exposure
//     lifted the mean from ~71% to ~75-78% and evened out the folds; adding
//     rotation/blur/noise pulled it back down.
// Any other dataset gets the light crop+flip default; re-test when it grows.
let augmentationByDataset: [String: MLImageClassifier.ImageAugmentationOptions] = [
    "PlantData": [],
    "PlantSymptoms": [.crop, .flip, .exposure],
]
var parameters = MLImageClassifier.ModelParameters(
    validation: .none,
    maxIterations: 30,
    augmentation: augmentationByDataset[dataURL.lastPathComponent] ?? [.crop, .flip],
    algorithm: .transferLearning(featureExtractor: .scenePrint(revision: 2), classifier: .logisticRegressor)
)

func percent(_ error: Double) -> String { String(format: "%.1f%%", (1 - error) * 100) }

// MARK: - Pass 1: measure on held-out photos

let heldOut = validationFiles.values.reduce(0) { $0 + $1.count }
print("\nPass 1/2 — training on \(trainingFiles.values.reduce(0) { $0 + $1.count }) photos, validating on \(heldOut) held-out photos...")

do {
    parameters.validation = .dataSource(.filesByLabel(validationFiles))
    let trial = try MLImageClassifier(trainingData: .filesByLabel(trainingFiles), parameters: parameters)

    print("  Training accuracy:   \(percent(trial.trainingMetrics.classificationError))")
    print("  Validation accuracy: \(percent(trial.validationMetrics.classificationError))  (photos the model never saw)")

    // Which plants get mixed up, if any
    let confusion = trial.validationMetrics.confusionDataFrame
    let columns = confusion.columns.map(\.name)
    // Column names vary between Create ML versions ("class" / "True Label" ...)
    let predictedColumn = columns.first { $0.lowercased().contains("predicted") }
    let actualColumn = columns.first { $0.lowercased().contains("class") || $0.lowercased().contains("label") }
        .flatMap { $0 == predictedColumn ? nil : $0 }
        ?? columns.first { $0.lowercased().contains("true") }
    let countColumn = columns.first { $0.lowercased().contains("count") }
    var mistakes: [(String, String, Int)] = []
    if let actualColumn, let predictedColumn, let countColumn {
        for row in confusion.rows {
            guard let actual = row[actualColumn] as? String,
                  let predicted = row[predictedColumn] as? String,
                  let count = row[countColumn] as? Int,
                  actual != predicted, count > 0 else { continue }
            mistakes.append((actual, predicted, count))
        }
    } else {
        print("  (couldn't read the confusion table; columns: \(columns))")
    }
    if mistakes.isEmpty && actualColumn != nil {
        print("  Every held-out photo was identified correctly.")
    } else {
        print("  Mistakes on held-out photos:")
        for (actual, predicted, count) in mistakes.sorted(by: { $0.2 > $1.2 }) {
            print("    \(actual) -> predicted \(predicted) (\(count))")
        }
    }
} catch {
    print("\nValidation training failed: \(error.localizedDescription)")
    exit(1)
}

// MARK: - Pass 2: final model on every photo

print("\nPass 2/2 — training the final model on all \(filesByLabel.values.reduce(0) { $0 + $1.count }) photos...")

do {
    parameters.validation = .none
    let classifier = try MLImageClassifier(trainingData: .filesByLabel(filesByLabel), parameters: parameters)
    print("  Training accuracy: \(percent(classifier.trainingMetrics.classificationError))")

    let classes = filesByLabel.keys.sorted().joined(separator: ", ")
    let metadata = MLModelMetadata(
        author: "Plant Farm",
        shortDescription: "Trained on \(dataURL.lastPathComponent). Classes: \(classes)",
        version: "1.0"
    )
    try classifier.write(to: outputURL, metadata: metadata)
    print("\nSaved model to: \(outputURL.path)")
    print("Classes: \(classes)")
    if outputURL.path.hasPrefix(appModelFolder.path) {
        print("Xcode will compile the new model into the app on the next build (Cmd + R).")
    } else {
        print("Copy it over PP/Frontend/ML/PlantClassifier.mlmodel in the app project to ship it.")
    }
} catch {
    print("\nTraining failed: \(error.localizedDescription)")
    exit(1)
}
