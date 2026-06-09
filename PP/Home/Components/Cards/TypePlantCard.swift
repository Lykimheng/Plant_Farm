//
//  TypePlantCard.swift
//  PP
//
//  Created by Ly Kimheng on 16/1/26.
//

import SwiftUI

struct TypePlantCard: View {
    let plant: PlantModel
    @EnvironmentObject var cart: CartModel
    @EnvironmentObject var wishlist: WishlistModel

    var body: some View {
        ZStack {
            // MARK: - Card Background
            RoundedRectangle(cornerRadius: 28)
                .fill(Color(red: 0.16, green: 0.40, blue: 0.40)) // dark teal

            // Curved accent background
            Color(red: 0.35, green: 0.70, blue: 0.70)
                .frame(width: 160, height: 180)
                .clipShape(
                    UnevenRoundedRectangle(
                        cornerRadii: .init(
                            topLeading: 28.0, // Top-left corner radius
                            bottomLeading: 40.0,
                            bottomTrailing: 150.0,
                            topTrailing: 40.0 // Top-right corner radius
                        )
                    )
                )
                .position(x: 80, y: 90)
            
            VStack(alignment: .leading, spacing: 10) {

                // MARK: - Top image + favorite
                ZStack(alignment: .topTrailing) {
                    HStack{
                        Image(plant.image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 280)
                            .padding(.top, 10)
                            .position(x: 45, y: 60)
                    }
                    Button {
                        wishlist.toggleItem(plant: plant)
                    } label: {
                        Image(systemName: wishlist.isWishlisted(plant) ? "heart.fill" : "heart")
                            .foregroundColor(wishlist.isWishlisted(plant) ? .red : .white)
                    }
                }

                
                // MARK: - Name
                Text(plant.name)
                    .font(.title3.bold())
                    .foregroundColor(.white)
                    .lineLimit(1)

                // MARK: - Type
                HStack{
                    HStack(spacing: 6) {
                        Image(plant.typePlant)
                            .resizable()
                            .frame(width: 16, height: 16)
                        
                        Text(plant.type)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Image(systemName: Constants.starIcon)
                        .foregroundColor(Color.orange)
                        .imageScale(.small)
                    Text(String(format: "$%.2f", plant.price))
                        .bold()
                        .foregroundStyle(Color.white.opacity(0.6))
                        .frame(width: 5, height: 5)
                    
                    Text("( \(plant.counting) )")
                        .foregroundStyle(Color.gray.opacity(0.6))
                        .frame(width: 5, height: 5)
                }
                .lineLimit(1)
                



                // MARK: - Price
                Text(String(format: "%.2f$", plant.price))
                        .font(.headline)
                        .foregroundColor(.white)
            }
            .padding(18)

            // MARK: - Add button
            VStack {
                Spacer()
                HStack {
                    Spacer()

                    Button {
                        cart.addItem(plant: plant)
                    } label: {
                        Image(systemName: Constants.plusIcon)
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .frame(width: 35, height: 35)
                            .background(Color(red: 0.35, green: 0.70, blue: 0.70))
                            .clipShape(Circle())
                    }
                }
            }
            .padding(14)
        }
        .clipped()
        .frame(width: 200, height: 300)
    }
}
#Preview {
    TypePlantCard(plant: PlantData.indoorPlants[0])
}
