//
//  DeliveryOption.swift
//  PP
//
//  Created by Ly Kimheng on 12/8/26.
//

import Foundation

nonisolated struct DeliveryOption: Identifiable, Hashable {
    let id: String
    let name: LocalizedStringResource
    let fee: Double
    let duration: LocalizedStringResource
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }

    static let standard = DeliveryOption(id: "standard", name: "Standard", fee: 1.50, duration: "3–5 days")
    static let express = DeliveryOption(id: "express", name: "Express", fee: 2.00, duration: "Next day")

    static let all: [DeliveryOption] = [.standard, .express]
}

nonisolated struct PaymentMethod: Identifiable, Hashable {
    let id: String
    let name: LocalizedStringResource
    let icon: String
    let detail: LocalizedStringResource
    let hint: LocalizedStringResource

    static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }

    var paysOnline: Bool { self != .cashOnDelivery }

    static let aba = PaymentMethod(
        id: "aba", name: "ABA Pay", icon: "building.columns", detail: "Pay from your ABA account",
        hint: "ABA Mobile opens with the amount ready. Confirm there, then come back to Plant Farm."
    )
    static let khqr = PaymentMethod(
        id: "khqr", name: "KHQR", icon: "qrcode", detail: "Scan to pay with any bank app",
        hint: "You'll get a KHQR code to scan with ABA Mobile or any KHQR bank app. You can also save it and scan it from your photos."
    )
    static let card = PaymentMethod(
        id: "card", name: "Visa / Mastercard", icon: Icons.card, detail: "Credit or debit card",
        hint: "You'll type your card number, expiry date and CVV on ABA PayWay's secure form. Plant Farm never sees your card details."
    )
    static let cashOnDelivery = PaymentMethod(
        id: "cod", name: "Cash on Delivery", icon: "banknote", detail: "Pay the courier on arrival",
        hint: "Pay the courier in cash when your plants arrive."
    )

    static let all: [PaymentMethod] = [.aba, .khqr, .card, .cashOnDelivery]
    static let online: [PaymentMethod] = all.filter(\.paysOnline)

    static func with(id: String) -> PaymentMethod {
        all.first { $0.id == id } ?? .cashOnDelivery
    }
}

nonisolated enum OrderNumber {
    static func generate() -> String {
        let stamp = Int(Date().timeIntervalSince1970) % 100_000
        let salt = Int.random(in: 100...999)
        return String(format: "PF-%05d%03d", stamp, salt)
    }
}
