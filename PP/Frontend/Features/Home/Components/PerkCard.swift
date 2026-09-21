//
//  DiscountCard.swift
//  PP
//
//  Created by Ly Kimheng on 22/1/26.
//

import SwiftUI

struct DiscountCard: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack{
            Text(title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.title.bold())
                .padding(.top, 20)
                .foregroundColor(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255, opacity: 1.0) )
            Text(subtitle)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.subheadline.bold())
                .foregroundStyle(Color.gray)
                .padding(.bottom, 20)
            
        }
        .padding(.horizontal, 16)
        .frame(width: 400, height: 120, alignment: .leading)
        .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(.sRGB, red: 32/255, green: 169/255, blue: 172/255, opacity: 1.0) , lineWidth: 6)
            )
            .cornerRadius(20)
    }
}

#Preview {
    VStack(spacing: 20){
        DiscountCard(title: "Membership", subtitle: "Discount 20% for every purchase.")
        DiscountCard(title: "Free 5 coupons", subtitle: "For new user.")
        DiscountCard(title: "Free delivery", subtitle: "For under 3km")
    }

}
