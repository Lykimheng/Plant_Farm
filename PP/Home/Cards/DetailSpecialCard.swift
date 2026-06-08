//
//  DetailSpecialCard.swift
//  PP
//
//  Created by Ly Kimheng on 9/4/26.
//
import SwiftUI

struct DetailSpecialCard: View {
    let plant: SpecialPlant
    @EnvironmentObject var cart: CartModel
    @Environment(\.dismiss) private var dismiss
    @State private var favoritebtn: Bool = false

    var body: some View {
        GeometryReader { geo in
            VStack {
                // MARK: - Top Bar
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
                        favoritebtn.toggle()
                    } label: {
                        Image(systemName: favoritebtn ? "heart.fill" : Constants.favoriteIcon)
                            .imageScale(.large)
                            .foregroundColor(favoritebtn ? .red : .white)
                    }
                }
                .frame(height: 70)
                .padding(.horizontal)

                // MARK: - Image + Rating
                VStack(spacing: 8) {
                    Image(plant.image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.6,      // ← 60% of screen width
                               height: geo.size.height * 0.28)   // ← 28% of screen height
                    
                    HStack(spacing: 4) {
                        Image(systemName: Constants.starIcon)
                            .foregroundColor(.orange)
                            .imageScale(.small)
                        Text("5.0")
                            .bold()
                            .foregroundStyle(Color.white.opacity(0.8))
                        Text("(39)")
                            .foregroundStyle(Color.white.opacity(0.5))
                    }
                }

                // MARK: - Detail Panel
                VStack(alignment: .leading, spacing: 8) {
                    Text(plant.name)
                        .foregroundStyle(Color(.sRGB, red: 32/255, green: 169/255, blue: 172/255))
                        .font(.largeTitle.bold())

                    Text(plant.type)
                        .foregroundStyle(.gray)
                        .font(.subheadline.bold())

                    Text("Description")
                        .foregroundStyle(.black)
                        .font(.title3.bold())

                    Text(plant.description)
                        .foregroundStyle(.gray)
                        .font(.system(size: 13))
                        .fixedSize(horizontal: false, vertical: true)  // ← wraps properly

                    Spacer()

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Price :")
                                .foregroundStyle(.black)
                                .font(.title3)
                            HStack(alignment: .firstTextBaseline, spacing: 8) {
                                Text(String(format: "$%.2f", plant.firstPrice))
                                    .foregroundStyle(.gray)
                                    .font(.subheadline)
                                    .strikethrough()
                                Text(String(format: "$%.2f", plant.price))
                                    .foregroundStyle(.black)
                                    .font(.title.bold())
                            }
                        }
                        Spacer()
                        Button {
                            cart.addItem(plant: plant.plant)
                        } label: {
                            Text("Add to Cart")
                                .frame(width: geo.size.width * 0.3,   // ← 30% of screen width
                                       height: 50)
                                .foregroundColor(.white)
                                .background(Color(red: 0.15, green: 0.70, blue: 0.70))
                                .cornerRadius(10)
                        }
                    }
                    .padding(.bottom, geo.safeAreaInsets.bottom + 16)  // ← respects safe area
                }
                .padding(.horizontal,)
                .padding(.bottom, 100)
                .frame(maxWidth: .infinity)
                .frame(height: geo.size.height * 0.58)                  // ← 50% of screen height
                .background(Color.white)
                .clipShape(
                    UnevenRoundedRectangle(cornerRadii: .init(topTrailing: 50.0))
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255))
        }
        .navigationBarHidden(true)
        .ignoresSafeArea(edges: .bottom)
    }
}
