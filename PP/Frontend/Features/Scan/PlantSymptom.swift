//
//  PlantSymptom.swift
//  PP
//
//  Created by Ly Kimheng on 17/9/26.
//

import Foundation

nonisolated enum PlantSymptom: String, CaseIterable, Hashable, Sendable {
    case healthy
    case yellowLeaves = "yellow_leaves"
    case brownTips = "brown_tips"
    case leafSpots = "leaf_spots"
    case wilting
    case pests
    case powderyMildew = "powdery_mildew"

    var displayName: LocalizedStringResource {
        switch self {
        case .healthy:       return "Looks healthy"
        case .yellowLeaves:  return "Yellowing leaves"
        case .brownTips:     return "Brown, crispy tips"
        case .leafSpots:     return "Spots on the leaves"
        case .wilting:       return "Wilting or drooping"
        case .pests:         return "Signs of pests"
        case .powderyMildew: return "Powdery mildew"
        }
    }

    var likelyCause: LocalizedStringResource {
        switch self {
        case .healthy:
            return "No sign of the common problems the scanner knows about."
        case .yellowLeaves:
            return "Most often overwatering or a pot that doesn't drain; sometimes too little light or a lack of nutrients."
        case .brownTips:
            return "Dry air, uneven watering, or salts building up from tap water and fertiliser."
        case .leafSpots:
            return "Usually a fungal or bacterial leaf-spot infection, encouraged by wet leaves and still air."
        case .wilting:
            return "Either thirst or the opposite — roots rotting in soggy soil. Feel the soil to tell which."
        case .pests:
            return "Webbing, white fluff, sticky residue or tiny dots point to spider mites, mealybugs, scale or aphids."
        case .powderyMildew:
            return "A white, powdery fungus that thrives in warm, humid, still air."
        }
    }

    var whatToDo: LocalizedStringResource {
        switch self {
        case .healthy:
            return "Keep doing what you're doing. Check the care tips above if you're unsure about light or watering."
        case .yellowLeaves:
            return "Let the top few centimetres of soil dry out before watering again, make sure the pot drains, and move it somewhere brighter."
        case .brownTips:
            return "Water more evenly, raise humidity by misting or grouping plants, and flush the soil with plenty of water every few months."
        case .leafSpots:
            return "Remove the worst leaves, keep water off the foliage, improve airflow, and use a fungicide if it keeps spreading."
        case .wilting:
            return "Dry soil: water thoroughly. Wet soil: let it dry out, check the roots, and repot into fresh mix if they're brown and mushy."
        case .pests:
            return "Isolate the plant, wipe the leaves with soapy water or neem oil, and repeat weekly until it's clear."
        case .powderyMildew:
            return "Cut off affected leaves, improve airflow, avoid wetting the foliage, and treat with a fungicide."
        }
    }
}

nonisolated struct HealthPrediction: Identifiable, Hashable, Sendable {
    let symptom: PlantSymptom
    let confidence: Double

    var id: PlantSymptom { symptom }

    init?(_ classification: Classification) {
        guard let symptom = PlantSymptom(rawValue: classification.label) else { return nil }
        self.symptom = symptom
        self.confidence = classification.confidence
    }

    var percentText: String { "\(Int((confidence * 100).rounded()))%" }
}
