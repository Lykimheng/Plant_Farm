//
//  OrderModel.swift
//  PP
//
//  Created by Ly Kimheng on 8/6/26.
//

import SwiftUI

struct OrderModel: Identifiable {
    let id = UUID()
    let orderNumber: String
    let date: String
    var status: OrderStatus
    let items: [CartItem]
    let total: Double
    let deliveryAddress: String

    enum OrderStatus: String {
        case pending = "Pedding"
        case confirmed = "Confirmed"
        case preparing = "Preparing"
        case inTransit = "In Transit"
        case delivered = "Delivered"
        case cancelled = "Cancelled"
        case rejected = "Rejected"
    }
}

// move color extension outside the enum
extension OrderModel.OrderStatus {
    var color: Color {
        switch self {
        case .pending:     return .orange
        case .confirmed:  return .blue
        case .preparing:  return .orange
        case .inTransit:  return .green
        case .delivered:  return Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255)
        case .cancelled:  return .red
        case .rejected:  return .red
        }
    }

    var statusText: String {
        self.rawValue
    }
}
