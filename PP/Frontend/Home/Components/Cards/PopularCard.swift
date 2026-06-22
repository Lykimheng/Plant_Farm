//
//  PopularCard.swift
//  PP
//
//  Created by Ly Kimheng on 10/1/26.
//

import SwiftUI

struct PopularCard: View {
    let plant: PlantModel
    @EnvironmentObject var cart: CartModel
    @EnvironmentObject var wishlist: WishlistModel
    var body: some View {
        ZStack(alignment: .bottom) {
            ZStack {
                // MARK: - Card Background
                RoundedRectangle(cornerRadius: 28)
                    .foregroundStyle(Color(red: 0.0/255.0, green: 41.0/255.0, blue: 45.0/255.0, opacity: 1.0))
                
                // Curved accent background
                Color(red: 0.0, green: 0.41, blue: 0.43, opacity: 1.0)
                    .frame(width: 180, height: 165)
                    .clipShape(
                        UnevenRoundedRectangle(
                            cornerRadii: .init(
                                topLeading: 50.0, // Top-left corner radius
                                bottomLeading: 30.0,
                                bottomTrailing: 60.0,
                                topTrailing: 150.0 // Top-right corner radius
                            )
                        )
                    )
                    .position(x: 60, y: 80)
                HStack {
                    HStack {
                    }
                    .frame(width: 150)
                    
                    VStack {
                        Spacer()
                        
                        Text(plant.name)
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .lineLimit(1)
                        HStack {
                            
                            RemoteImage(urlString: APIService.shared.categoryIconURL(plant.typePlant))
                                .frame(width: 16, height: 16)
                            
                            Text(plant.typePlant)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Text(String(format: "%.2f$", plant.price))
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    VStack {
                        Spacer()
                        Button {
                            wishlist.toggleItem(plant: plant)
                        } label: {
                            Image(systemName: wishlist.isWishlisted(plant) ? "heart.fill" : "heart")
                                .foregroundColor(wishlist.isWishlisted(plant) ? .red : .white)
                        }
                        
                        Spacer()
                        Button {
                            cart.addItem(plant: plant)
                        } label: {
                            Image(systemName: "plus")
                                .font(.title2.bold())
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(Color(red: 0.35, green: 0.70, blue: 0.70))
                                .clipShape(Circle())
                        }
                        Spacer()
                    }
                    Spacer()
                }
            }
            .frame(width: 380, height: 160)
            .cornerRadius(20)
            
            RemoteImage(urlString: plant.image)
                .scaledToFit()
                .padding(.top, 10)
                .position(x: 75, y: 70)
        }
        .frame(width: 380, height: 180)
    }
}
