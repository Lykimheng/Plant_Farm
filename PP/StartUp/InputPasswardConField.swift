//
//  InputPasswardConField.swift
//  PP
//
//  Created by Ly Kimheng on 27/12/25.
//

import SwiftUI

struct InputPasswardConField: View {
    @Binding var password: String
       @State private var isVisible = false

       var body: some View {
           HStack {
               Image(systemName: "lock")
                   .foregroundColor(.gray)

               Group {
                   if isVisible {
                       TextField("Confirm Password", text: $password)
                   } else {
                       SecureField("Confirm Password", text: $password)
                   }
               }
               .autocapitalization(.none)

               Button {
                   isVisible.toggle()
               } label: {
                   Image(systemName: isVisible ? Constants.eyeOffIcon : Constants.eyeIcon)
                       .foregroundColor(.gray)
               }
           }
           .padding()
           .frame(height: 50)
           .background(Color.white.opacity(0.9))
           .overlay(
               RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.sRGB, red: 32/255, green: 169/255, blue: 172/255, opacity: 1.0), lineWidth: 1.0)
           )
           .cornerRadius(12)
       }
}
