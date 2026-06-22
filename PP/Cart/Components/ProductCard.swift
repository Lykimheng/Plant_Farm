//
//  ProductCard.swift
//  PP
//
//  Created by Ly Kimheng on 25/12/25.
//
import SwiftUI

struct ProductCard: View {
    let image: String
    let productName: String
    let price: String
    let quantity: Int                  // ← replace @State var ammount
    var onIncrease: () -> Void         // ← add
    var onDecrease: () -> Void         // ← add
    var onDelete: () -> Void           // ← add

    var body: some View {
        HStack {
            HStack(spacing: 12) {
                RemoteImage(urlString: image)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .padding(10)

                VStack(alignment: .leading) {
                    Text(productName)
                        .font(.headline)
                    Text("$" + price)
                        .font(.title2)
                        .bold()
                        .padding(2)
                }
            }

            Spacer()

            VStack {
                Button("Trash", systemImage: "trash") {
                    onDelete()                         // ← call callback
                }
                .foregroundColor(Color(.sRGB, red: 32/255, green: 169/255, blue: 172/255))
                .labelStyle(.iconOnly)

                HStack {
                    Button("Decrease", systemImage: "minus.circle.fill") {
                        onDecrease()                   // ← call callback
                    }
                    .foregroundStyle(Color(.sRGB, red: 176/255, green: 176/255, blue: 176/255))
                    .disabled(quantity == 1)            // ← use quantity
                    .labelStyle(.iconOnly)

                    Text(quantity, format: .number.precision(.integerLength(2)))
                        .font(.title3.bold())

                    Button("Increase", systemImage: "plus.circle.fill") {
                        onIncrease()                   // ← call callback
                    }
                    .foregroundStyle(Color(.sRGB, red: 32/255, green: 169/255, blue: 172/255))
                    .disabled(quantity == 10)           // ← use quantity
                    .labelStyle(.iconOnly)
                }
                .padding()
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(.sRGB, red: 32/255, green: 169/255, blue: 172/255))
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 5)
    }
}
