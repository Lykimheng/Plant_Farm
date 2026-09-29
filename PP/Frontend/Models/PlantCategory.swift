//
//  PlantCategory.swift
//  PP
//
//  Created by Ly Kimheng on 12/8/26.
//

import Foundation

nonisolated enum PlantCategory: String, CaseIterable, Identifiable, Hashable {
    case all
    case indoor
    case outdoor
    case aquatic
    case bigTree
    case other

    var id: String { rawValue }
    static var browsable: [PlantCategory] { [.all, .indoor, .outdoor, .aquatic, .bigTree] }

    init(apiValue: String) {
        switch apiValue {
        case "indoorPlant":  self = .indoor
        case "outdoorPlant": self = .outdoor
        case "aquaticPlant": self = .aquatic
        case "bigTree":      self = .bigTree
        default:             self = .other
        }
    }

    var title: LocalizedStringResource {
        switch self {
        case .all:     return "All"
        case .indoor:  return "Indoor"
        case .outdoor: return "Outdoor"
        case .aquatic: return "Aquatic"
        case .bigTree: return "Big Tree"
        case .other:   return "Other"
        }
    }
    
    var sectionTitle: LocalizedStringResource {
        switch self {
        case .all:     return "All Plants"
        case .indoor:  return "Indoor Plants"
        case .outdoor: return "Outdoor Plants"
        case .aquatic: return "Aquatic Plants"
        case .bigTree: return "Big Trees"
        case .other:   return "More Plants"
        }
    }
}
