//
//  DetailCard.swift
//  PP
//
//  Created by Ly Kimheng on 22/1/26.
//

import SwiftUI
struct DetailCard: View {
    let plant: PlantModel
    @EnvironmentObject var cart: CartModel
    @EnvironmentObject var wishlist: WishlistModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        GeometryReader { geo in
            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: Constants.closeIcon)
                            .imageScale(.large)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Button {
                        wishlist.toggleItem(plant: plant)
                    } label: {
                        Image(systemName: wishlist.isWishlisted(plant) ? "heart.fill" : "heart")
                            .foregroundColor(wishlist.isWishlisted(plant) ? .red : .white)
                    }
                }
                .frame(height: 70)
                .padding()
                
                VStack {
                    RemoteImage(urlString: plant.image)
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.6,
                               height: geo.size.height * 0.28)
                    HStack {
                        Image(systemName: Constants.starIcon)
                            .foregroundColor(.orange)
                        Text(String(format: "%.1f", plant.rating)).bold()
                            .foregroundStyle(Color.white.opacity(0.8))
                        Text("(\(plant.counting))")
                            .foregroundStyle(Color.white.opacity(0.5))
                    }
                }
                
                VStack(alignment: .leading) {
                    Text(plant.name)
                        .foregroundStyle(Color(.sRGB, red: 32/255, green: 169/255, blue: 172/255))
                        .font(.largeTitle.bold())
                    Text(plant.type)
                        .foregroundStyle(.gray)
                        .font(.subheadline.bold())
                        .padding(.bottom, 5)
                    
                    Text("Description")
                        .font(.title3.bold())
                        .padding(.bottom, 5)
                    
                    Text(plant.description)
                        .foregroundStyle(.gray)
                        .font(.system(size: 13))
                    
                    Spacer()
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Price :")
                                .font(.title3)
                            Text(String(format: "$%.2f", plant.price))
                                .font(.title.bold())
                        }
                        Spacer()
                        Button {
                            cart.addItem(plant: plant)
                        } label: {
                            Text("Add to Cart")
                                .frame(width: geo.size.width * 0.3, height: 50)
                                .foregroundColor(.white)
                                .background(Color(red: 0.15, green: 0.70, blue: 0.70))
                                .cornerRadius(10)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal,)
                .padding(.bottom, 100)
                .frame(maxWidth: .infinity)
                .frame(height: geo.size.height * 0.58)
                .background(Color.white)
                .clipShape(UnevenRoundedRectangle(cornerRadii: .init(topTrailing: 50.0)))
                .ignoresSafeArea(edges: .bottom)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255))
            .navigationBarHidden(true)  // ← hide default nav bar
            .ignoresSafeArea(edges: .bottom)
        }
    }
}
