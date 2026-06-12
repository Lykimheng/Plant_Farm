//
//  MyPlantCard.swift
//  PP
//
//  Created by Ly Kimheng on 9/6/26.
//

import SwiftUI

struct MyPlantCard: View {
    let plant: MyPlantModel
    var notifaction: Bool = false
    var onDelete: () -> Void
    var onToggle: () -> Void = { }

    var body: some View {
        VStack(spacing: 0) {

            // MARK: - Image
            ZStack(alignment: .bottomLeading) {
                Image(plant.image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 180)
                    .clipped()

                // care level badge
                HStack(spacing: 4) {
                    Image(systemName: plant.careLevel.icon)
                        .font(.caption.bold())
                    Text(plant.careLevel.rawValue)
                        .font(.caption.bold())
                }
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(plant.careLevel.color)
                .cornerRadius(20)
                .padding(12)

                // notification bell
                VStack {
                    HStack {
                        Spacer()
                        Button { } label: {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.8))
                                    .frame(width: 36, height: 36)
                                Image(systemName: notifaction ? Constants.notificationIcon : Constants.notificationIcon )
                                    .foregroundColor(.gray)
                                    .font(.system(size: 14))
                            }
                        }
                        .padding(12)
                    }
                    Spacer()
                }
            }
            .frame(height: 180)
            .clipped()

            // MARK: - Info
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(plant.name)
                            .font(.headline.bold())
                        Text(plant.species)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Button { } label: {
                        Image(systemName: "calendar")
                            .foregroundColor(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255))
                    }
                }

                Divider()

                // watering or sunlight info
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("WATERING")
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .tracking(1)
                        Text(plant.nextWatering)
                            .font(.subheadline.bold())
                    }
                    Spacer()
                    Button { } label: {
                        ZStack {
                            Circle()
                                .stroke(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255), lineWidth: 1.5)
                                .frame(width: 36, height: 36)
                            Image(systemName: "drop")
                                .foregroundColor(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255))
                                .font(.system(size: 14))
                        }
                    }
                }
            }
            .padding(16)
            .background(Color.white)
        }
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 6)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255, opacity: 1.0) , lineWidth: 1)
        )
        .contextMenu {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Remove Plant", systemImage: "trash")
            }
        }
    }
}
