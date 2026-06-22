//
//  FavoriteView.swift
//  PP
//
//  Created by Ly Kimheng on 8/6/26.
//

import SwiftUI

struct WishlistView: View {
    @EnvironmentObject var wishlist: WishlistModel
    @EnvironmentObject var cart: CartModel
    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 4) {
                // subtitle
                Text("\(wishlist.items.count) plants saved for later")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.horizontal)

                if wishlist.items.isEmpty {
                    // empty state
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "heart.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.4))
                        Text("No plants saved yet")
                            .font(.title3)
                            .foregroundColor(.gray)
                        Text("Tap the heart icon on any plant to save it here")
                            .font(.caption)
                            .foregroundColor(.gray.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        Spacer()
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(wishlist.items) { plant in
                                NavigationLink(value: plant) {
                                    WishlistCard(plant: plant)
                                }
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .navigationTitle("My Wishlist")
            .toolbar {
                if !wishlist.items.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Clear All") {
                            wishlist.clearAll()
                        }
                        .foregroundColor(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255))
                    }
                }
            }
            .navigationDestination(for: PlantModel.self) { plant in
                DetailCard(plant: plant)
            }
            .preferredColorScheme(.light)
        }
    }
}
#Preview{
    WishlistView()
}
