//
//  PaymentMethodsView.swift
//  PP
//
//  Created by Ly Kimheng on 8/6/26.
//

import SwiftUI

struct PaymentMethodsView: View {
    @AppStorage("preferredPaymentMethod") private var preferredMethodID = PaymentMethod.all[0].id

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.lg) {
                SectionCard(title: "Accepted at checkout", icon: Icons.card) {
                    VStack(spacing: 0) {
                        ForEach(PaymentMethod.all) { method in
                            PaymentMethodRow(
                                method: method,
                                isSelected: preferredMethodID == method.id
                            ) {
                                preferredMethodID = method.id
                            }

                            if method != PaymentMethod.all.last {
                                Divider().overlay(Theme.separator).padding(.leading, 56)
                            }
                        }
                    }
                }

                securityNote
            }
            .padding(Theme.Spacing.lg)
            .readableWidth()
        }
        .background(Theme.background)
        .navigationTitle("Payment Methods")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var securityNote: some View {
        HStack(alignment: .top, spacing: Theme.Spacing.md) {
            Image(systemName: "lock.shield")
                .font(.system(size: 16))
                .foregroundStyle(Theme.success)

            VStack(alignment: .leading, spacing: 3) {
                Text("Your details stay with your bank")
                    .font(.system(size: 13.5, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)
                Text("Plant Farm never stores card numbers. Payment is completed in your bank's own app or page when you place an order.")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface(padding: Theme.Spacing.lg)
    }
}

#Preview {
    NavigationStack { PaymentMethodsView() }
}
