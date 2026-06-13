//
//  FavoriteCard.swift
//  PP
//
//  Created by Ly Kimheng on 8/6/26.
//

import SwiftUI

struct WishlistCard: View {
    let plant: PlantModel
    @EnvironmentObject var wishlist: WishlistModel
    @EnvironmentObject var cart: CartModel
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                // plant image
                Image(plant.image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 160)
                    .clipped()
                    .cornerRadius(12, corners: [.topLeft, .topRight])

                // remove button
                Button {
                    wishlist.removeItem(plant: plant)
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 32, height: 32)
                            .shadow(radius: 2)
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.red)
                    }
                }
                .padding(8)
            }
            .background(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255))

            VStack(alignment: .leading, spacing: 6) {
                // rating
                HStack(spacing: 4) {
                    Image(systemName: "star")
                        .font(.caption)
                        .foregroundColor(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255))
                    Text(String(format: "%.1f", plant.rating))
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                // name
                Text(plant.name)
                    .font(.headline)
                    .foregroundColor(.black)
                    .lineLimit(1)

                // price
                Text(String(format: "$%.2f", plant.price))
                    .font(.subheadline.bold())
                    .foregroundColor(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255))

                // add to cart button
                Button {
                    cart.addItem(plant: plant)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "cart")
                        Text("Add to Cart")
                            .font(.subheadline.bold())
                    }
                    .frame(maxWidth: .infinity, minHeight: 40)
                    .foregroundColor(.white)
                    .background(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255))
                    .cornerRadius(8)
                }
            }
            .padding(10)
            .background(Color.white)
            .cornerRadius(12, corners: [.bottomLeft, .bottomRight])
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.08), radius: 6)
    }
}
