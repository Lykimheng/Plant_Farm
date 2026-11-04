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
    var logo: String? = nil
    let detail: LocalizedStringResource
    let hint: LocalizedStringResource

    static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }

    var paysOnline: Bool { self != .cashOnDelivery }

    static let abaKHQR = PaymentMethod(
        id: "khqr", name: "ABA KHQR", icon: "qrcode", logo: "PayABAKHQR", detail: "Scan to pay with any banking app",
        hint: "ABA Mobile opens if you have it. Otherwise you'll get a KHQR code to scan with any banking app."
    )
    static let card = PaymentMethod(
        id: "card", name: "Credit/Debit Card", icon: Icons.card, logo: "PayCardTile", detail: "Credit or debit card",
        hint: "You'll type your card number, expiry date and CVV on ABA PayWay's secure form. Plant Farm never sees your card details."
    )
    static let cashOnDelivery = PaymentMethod(
        id: "cod", name: "Cash on Delivery", icon: "banknote", detail: "Pay the courier on arrival",
        hint: "Pay the courier in cash when your plants arrive."
    )

    static let all: [PaymentMethod] = [.abaKHQR, .card, .cashOnDelivery]

    static func with(id: String) -> PaymentMethod {
        // "aba" was its own method before ABA merged ABA Pay and KHQR
        id == "aba" ? .abaKHQR : all.first { $0.id == id } ?? .cashOnDelivery
    }
}

nonisolated enum OrderNumber {
    static func generate() -> String {
        let stamp = Int(Date().timeIntervalSince1970) % 100_000
        let salt = Int.random(in: 100...999)
        return String(format: "PF-%05d%03d", stamp, salt)
    }
}
