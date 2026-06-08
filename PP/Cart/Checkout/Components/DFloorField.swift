//
//  DFloorField.swift
//  PP
//
//  Created by Ly Kimheng on 22/3/26.
//

import SwiftUI

struct DFloorField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false

    var body: some View {
        HStack {
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
                    .autocapitalization(.none)
            }
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
