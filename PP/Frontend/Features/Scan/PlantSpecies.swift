//
//  PlantSpecies.swift
//  PP
//
//  Created by Ly Kimheng on 16/9/26.
//

import Foundation

nonisolated enum PlantSpecies: String, CaseIterable, Hashable, Sendable {
    case aloeVera = "aloe_vera"
    case cactus
    case chineseEvergreen = "chinese_evergreen"
    case fiddleLeafFig = "fiddle_leaf_fig"
    case luckyBamboo = "lucky_bamboo"
    case mangoTree = "mango_tree"
    case monstera
    case peaceLily = "peace_lily"
    case pothos
    case snakePlant = "snake_plant"
    case spiderPlant = "spider_plant"
    case zzPlant = "zz_plant"

    var displayName: String {
        switch self {
        case .aloeVera:         return "Aloe Vera"
        case .cactus:           return "Cactus"
        case .chineseEvergreen: return "Chinese Evergreen"
        case .fiddleLeafFig:    return "Fiddle Leaf Fig"
        case .luckyBamboo:      return "Lucky Bamboo"
        case .mangoTree:        return "Mango Tree"
        case .monstera:         return "Monstera"
        case .peaceLily:        return "Peace Lily"
        case .pothos:           return "Pothos"
        case .snakePlant:       return "Snake Plant"
        case .spiderPlant:      return "Spider Plant"
        case .zzPlant:          return "ZZ Plant"
        }
    }

    var scientificName: String {
        switch self {
        case .aloeVera:         return "Aloe barbadensis"
        case .cactus:           return "Cactaceae"
        case .chineseEvergreen: return "Aglaonema"
        case .fiddleLeafFig:    return "Ficus lyrata"
        case .luckyBamboo:      return "Dracaena sanderiana"
        case .mangoTree:        return "Mangifera indica"
        case .monstera:         return "Monstera deliciosa"
        case .peaceLily:        return "Spathiphyllum"
        case .pothos:           return "Epipremnum aureum"
        case .snakePlant:       return "Sansevieria trifasciata"
        case .spiderPlant:      return "Chlorophytum comosum"
        case .zzPlant:          return "Zamioculcas zamiifolia"
        }
    }
    
    var catalogKeywords: [String] {
        switch self {
        case .aloeVera:         return ["aloe"]
        case .cactus:           return ["cactus", "cacti"]
        case .chineseEvergreen: return ["chinese evergreen", "aglaonema"]
        case .fiddleLeafFig:    return ["fiddle", "ficus lyrata"]
        case .luckyBamboo:      return ["lucky bamboo", "dracaena sanderiana"]
        case .mangoTree:        return ["mango"]
        case .monstera:         return ["monstera", "swiss cheese"]
        case .peaceLily:        return ["peace lily", "spathiphyllum"]
        case .pothos:           return ["pothos", "devil's ivy", "devils ivy", "epipremnum"]
        case .snakePlant:       return ["snake plant", "sansevieria", "mother-in-law"]
        case .spiderPlant:      return ["spider plant", "chlorophytum"]
        case .zzPlant:          return ["zz plant", "zamioculcas", "zanzibar gem"]
        }
    }

    var light: String {
        switch self {
        case .aloeVera, .fiddleLeafFig, .luckyBamboo, .monstera, .spiderPlant:
            return "Bright, indirect light"
        case .cactus, .mangoTree:
            return "Full sun"
        case .chineseEvergreen, .peaceLily:
            return "Low to medium indirect light"
        case .pothos, .zzPlant:
            return "Low to bright indirect light"
        case .snakePlant:
            return "Anything from low light to full sun"
        }
    }

    var water: String {
        switch self {
        case .aloeVera:         return "Every 2–3 weeks, once the soil is fully dry"
        case .cactus:           return "Every 2–4 weeks; barely at all in winter"
        case .chineseEvergreen: return "Weekly, when the top inch of soil is dry"
        case .fiddleLeafFig:    return "Every 7–10 days when the top 2 inches are dry"
        case .luckyBamboo:      return "Keep roots in 1–2 inches of clean water; change it weekly"
        case .mangoTree:        return "Deeply once or twice a week while young"
        case .monstera:         return "Weekly; let the top few inches dry out first"
        case .peaceLily:        return "Weekly, or as soon as the leaves start to droop"
        case .pothos:           return "Every 1–2 weeks when the soil is dry"
        case .snakePlant:       return "Every 2–4 weeks; overwatering is the main risk"
        case .spiderPlant:      return "Weekly; keep the soil lightly moist"
        case .zzPlant:          return "Every 2–3 weeks; let it dry out completely"
        }
    }
}

nonisolated struct PlantPrediction: Identifiable, Hashable, Sendable {
    let species: PlantSpecies
    let confidence: Double

    var id: PlantSpecies { species }

    init?(_ classification: Classification) {
        guard let species = PlantSpecies(rawValue: classification.label) else { return nil }
        self.species = species
        self.confidence = classification.confidence
    }

    var percentText: String { "\(Int((confidence * 100).rounded()))%" }

    enum Certainty { case high, likely, low }

    var certainty: Certainty {
        switch confidence {
        case 0.75...: return .high
        case 0.45...: return .likely
        default:      return .low
        }
    }
}
