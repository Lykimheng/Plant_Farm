//
//  CategoryButton.swift
//  PP
//
//  Created by Ly Kimheng on 25/12/25.
//

import SwiftUI

struct CategoryButton: View {
    let title: String
    var isSelected: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button{
            action()
        } label:{
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    isSelected ? Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255, opacity: 1.0) : Color.clear
                )
                .foregroundColor(isSelected ? .white : Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255, opacity: 1.0) )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255, opacity: 1.0) , lineWidth: 1)
                )
                .cornerRadius(20)
        }
    }
}
#Preview {
    CategoryButton(title: "Hello", isSelected: false){}
}
