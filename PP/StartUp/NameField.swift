//
//  NameField.swift
//  PP
//
//  Created by Ly Kimheng on 8/1/26.
//

import SwiftUI

struct NameField: View {
    @Binding var name: String

       var body: some View {
           HStack {
                    TextField("Ly Kimheng", text: $name)
           }
           .padding()
           .frame(height: 50)
           .background(Color.white.opacity(0.9))
           .overlay(
               RoundedRectangle(cornerRadius: 12)
                   .stroke(Color(.sRGB, red: 32/255, green: 169/255, blue: 172/255, opacity: 1.0), lineWidth: 1)
           )
           .cornerRadius(12)
       }
}


