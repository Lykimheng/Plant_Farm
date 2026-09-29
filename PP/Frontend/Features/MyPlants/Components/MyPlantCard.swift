//
//  MyPlantCard.swift
//  PP
//
//  Created by Ly Kimheng on 9/6/26.
//

import SwiftUI

struct MyPlantCard: View {
    let plant: MyPlantModel
    var onDelete: () -> Void

    @State private var showDeleteConfirm = false

    var body: some View {
        VStack(spacing: 0) {
            RemoteImage(urlString: plant.image)
                .scaledToFill()
                .frame(height: 168)
                .frame(maxWidth: .infinity)
                .clipped()
                .background(Theme.surfaceAlt)
                .overlay(alignment: .bottomLeading) { careBadge }

            details
        }
        .cardBackground()
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg, style: .continuous))
        .contextMenu {
            Button("Remove plant", systemImage: Icons.trash, role: .destructive) {
                showDeleteConfirm = true
            }
        }
        .confirmationDialog(
            "Remove \(plant.name)?",
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Remove", role: .destructive, action: onDelete)
            Button("Keep", role: .cancel) {}
        } message: {
            Text("It will be removed from your plant tracker.")
        }
    }

    private var careBadge: some View {
        Label(plant.careLevel.displayName, systemImage: plant.careLevel.icon)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(Theme.onBrand)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(plant.careLevel.color, in: Capsule())
            .padding(Theme.Spacing.md)
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            VStack(alignment: .leading, spacing: 2) {
                Text(plant.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)
                (plant.species.isBlank ? Text("Species not set") : Text(plant.species))
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.textTertiary)
            }

            Divider().overlay(Theme.separator)

            HStack(spacing: Theme.Spacing.lg) {
                careFact(icon: Icons.waterFilled, label: "Watering", value: plant.nextWatering)
                careFact(icon: Icons.sun, label: "Light", value: plant.sunlight)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Theme.Spacing.lg)
    }

    /// `value` is what the server stored — the English wording picked in
    /// AddMyPlantView — so it's translated by looking that text up.
    private func careFact(icon: String, label: LocalizedStringResource, value: String) -> some View {
        HStack(spacing: Theme.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundStyle(Theme.brand)
                .frame(width: 28, height: 28)
                .background(Theme.brandTint, in: Circle())

            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .textCase(.uppercase)
                    .font(.system(size: 9.5, weight: .semibold))
                    .tracking(0.5)
                    .foregroundStyle(Theme.textTertiary)
                (value.isBlank ? Text("Not set") : Text(LocalizedStringResource.dynamic(value)))
                    .font(.system(size: 12.5, weight: .medium))
                    .foregroundStyle(Theme.textPrimary)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    MyPlantCard(
        plant: MyPlantModel(
            image: "", name: "Monstera", species: "Monstera deliciosa",
            careLevel: .moderate, nextWatering: "In 3 days", sunlight: "Partial"
        ),
        onDelete: {}
    )
    .padding()
    .background(Theme.background)
}
