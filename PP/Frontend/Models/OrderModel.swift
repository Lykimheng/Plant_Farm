//
//  OrderModel.swift
//  PP
//
//  Created by Ly Kimheng on 8/6/26.
//

import SwiftUI

nonisolated struct OrderModel: Identifiable, Hashable {
    let id = UUID()
    var apiId: Int = 0
    let orderNumber: String
    let placedAt: Date
    var status: OrderStatus
    let items: [CartItem]
    let total: Double
    let deliveryAddress: String
    var paymentMethod: PaymentMethod = .cashOnDelivery
    var paymentStatus: PaymentStatus = .unpaid
    var itemCount: Int { items.reduce(0) { $0 + $1.quantity } }
    static func == (lhs: OrderModel, rhs: OrderModel) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }

    var isPaid: Bool { paymentStatus == .paid }

    var awaitsOnlinePayment: Bool {
        paymentMethod.paysOnline && paymentStatus == .unpaid && !status.isTerminated
    }

    var canCancel: Bool { status.isCancellable && !isPaid }

    enum PaymentStatus: String {
        case unpaid, paid, refunded

        init(apiValue: String?) {
            self = PaymentStatus(rawValue: apiValue ?? "") ?? .unpaid
        }

        var label: LocalizedStringResource {
            switch self {
            case .unpaid:   return "Unpaid"
            case .paid:     return "Paid"
            case .refunded: return "Refunded"
            }
        }
    }

    enum OrderStatus: String, CaseIterable {
        case pending = "Pending"
        case confirmed = "Confirmed"
        case preparing = "Preparing"
        case inTransit = "In Transit"
        case delivered = "Delivered"
        case cancelled = "Cancelled"
        case rejected = "Rejected"
        
        init(apiValue: String) {
            switch apiValue {
            case "confirmed": self = .confirmed
            case "preparing": self = .preparing
            case "inTransit": self = .inTransit
            case "delivered": self = .delivered
            case "cancelled": self = .cancelled
            case "rejected":  self = .rejected
            default:          self = .pending
            }
        }

        var apiValue: String {
            switch self {
            case .pending:   return "pending"
            case .confirmed: return "confirmed"
            case .preparing: return "preparing"
            case .inTransit: return "inTransit"
            case .delivered: return "delivered"
            case .cancelled: return "cancelled"
            case .rejected:  return "rejected"
            }
        }

        var label: LocalizedStringResource {
            switch self {
            case .pending:   return "Pending"
            case .confirmed: return "Confirmed"
            case .preparing: return "Preparing"
            case .inTransit: return "In Transit"
            case .delivered: return "Delivered"
            case .cancelled: return "Cancelled"
            case .rejected:  return "Rejected"
            }
        }
        
        static let fulfilmentSteps: [OrderStatus] = [.pending, .confirmed, .preparing, .inTransit, .delivered]
        
        var isTerminated: Bool { self == .cancelled || self == .rejected }
        
        var isCancellable: Bool { self == .pending }
        
        var color: Color {
            switch self {
            case .pending, .preparing: return Theme.warning
            case .confirmed:           return Theme.info
            case .inTransit:           return Theme.brandAccent
            case .delivered:           return Theme.success
            case .cancelled, .rejected: return Theme.danger
            }
        }

        var icon: String {
            switch self {
            case .pending:    return "clock"
            case .confirmed:  return "checkmark.circle"
            case .preparing:  return "shippingbox"
            case .inTransit:  return Icons.truck
            case .delivered:  return "house"
            case .cancelled:  return "xmark.circle"
            case .rejected:   return "exclamationmark.triangle"
            }
        }
    }
}
