//
//  PlantCard.swift
//  PP
//
//  Created by Ly Kimheng on 24/12/25.
//

import SwiftUI

struct PlantCard: View {
    let plant: SpecialPlant
    @EnvironmentObject var cart: CartModel
    @EnvironmentObject var wishlist: WishlistModel
    
    var body: some View {
        NavigationLink(value: plant){
            ZStack {
                // MARK: - Card Background
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color(red: 0.16, green: 0.40, blue: 0.40))
                
                // Curved accent background
                Color(red: 0.35, green: 0.70, blue: 0.70)
                    .frame(width: 140, height: 150)
                    .clipShape(
                        UnevenRoundedRectangle(
                            cornerRadii: .init(
                                topLeading: 28.0, // Top-left corner radius
                                bottomLeading: 40.0,
                                bottomTrailing: 160.0,
                                topTrailing: 40.0 // Top-right corner radius
                            )
                        )
                    )
                    .position(x: 70, y: 75)
                
                VStack(alignment: .leading) {
                    
                    // MARK: - Top image + favorite
                    ZStack(alignment: .topTrailing) {
                        HStack{
                            RemoteImage(urlString: plant.image)
                                .scaledToFit()
                                .frame(height: 150)
                                .padding(.top, 10)
                                .position(x: 45, y: 50)
                        }
                        Button {
                            wishlist.toggleItem(plant: plant.plant)
                        } label: {
                            Image(systemName: wishlist.isWishlisted(plant.plant) ? "heart.fill" : "heart")
                                .foregroundColor(wishlist.isWishlisted(plant.plant) ? .red : .white)
                        }
                    }
                    
                    Spacer()
                    
                    // MARK: - Type
                    HStack(spacing: 6) {
                        RemoteImage(urlString: APIService.shared.categoryIconURL(plant.typePlant))
                            .frame(width: 16, height: 16)
                        
                        Text(plant.type)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    // MARK: - Name
                    Text(plant.name)
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    // MARK: - Price
                    VStack(alignment: .leading, spacing: 2) {
                        Text(String(format: "%.2f$", plant.firstPrice))
                            .font(.caption)
                            .foregroundStyle(Color(.sRGB, red: 255/255, green: 200/255, blue: 201/255))
                            .strikethrough()
                        
                        Text(String(format: "%.2f$", plant.price))
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
                .padding(18)
                
                // MARK: - Add button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        
                        Button {
                            cart.addItem(plant: plant.plant)
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
}
