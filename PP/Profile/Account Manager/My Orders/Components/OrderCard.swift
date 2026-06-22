//
//  OrderCard.swift
//  PP
//
//  Created by Ly Kimheng on 8/6/26.
//

import SwiftUI

struct OrderCard: View {
    let order: OrderModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // top row
            HStack {
                Text("Order #\(order.orderNumber)")
                    .font(.headline.bold())
                Spacer()
                // status badge
                Text(order.status.rawValue)
                    .font(.caption.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(order.status.color) 
                    .cornerRadius(20)
            }

            Text(order.date)
                .font(.caption)
                .foregroundColor(.gray)

            Divider()

            // items preview
            HStack(spacing: 8) {
                ForEach(order.items.prefix(3)) { item in
                    RemoteImage(urlString: item.plant.image)
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .cornerRadius(8)
                }
                if order.items.count > 3 {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray5))
                            .frame(width: 50, height: 50)
                        Text("+\(order.items.count - 3)")
                            .font(.caption.bold())
                            .foregroundColor(.gray)
                    }
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("\(order.items.count) items")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(String(format: "$%.2f", order.total))
                        .font(.headline.bold())
                        .foregroundColor(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255))
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4)
    }
}
