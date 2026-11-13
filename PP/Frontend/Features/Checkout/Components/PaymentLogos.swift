//
//  PaymentLogos.swift
//  PP
//
//  Created by Ly Kimheng on 4/11/26.
//

import SwiftUI

struct PaymentMethodIcon: View {
    let method: PaymentMethod
    var size: CGFloat = 40

    var body: some View {
        if let logo = method.logo {
            Image(logo)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: size / 6, style: .continuous))
                .accessibilityHidden(true)
        } else {
            Image(systemName: method.icon)
                .font(.system(size: 16))
                .foregroundStyle(Theme.brand)
                .frame(width: size, height: size)
                .background(Theme.brandTint, in: RoundedRectangle(cornerRadius: Theme.Radius.sm, style: .continuous))
                .accessibilityHidden(true)
        }
    }
}

struct PaymentBrandMarks: View {
    static let cards = ["PayVisa", "PayMastercard", "PayUnionPay", "PayJCB"]

    var marks = Self.cards

    var body: some View {
        HStack(spacing: 4) {
            ForEach(marks, id: \.self) { mark in
                Image(mark)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 20)
                    .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
            }
        }
    }
}
