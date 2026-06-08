//
//  EnterAddress.swift
//  PP
//
//  Created by Ly Kimheng on 24/3/26.
//

import SwiftUI

struct EnterAddressField: View {
    @Environment(\.dismiss) var dismiss
        let placeholder: String
        @Binding var text: String
        var isSecure: Bool = false

        var body: some View {
            HStack {
                Image(systemName: Constants.searchIcon)
                    .foregroundColor(.gray)
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                        .autocapitalization(.none)
                }
                Button{
                    dismiss()
                }label: {
                    Image(systemName: Constants.closeCircleIcon)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .frame(height: 50)
            .background(Color.white.opacity(0.9))
            .overlay(
                RoundedRectangle(cornerRadius: 50)
                    .stroke(Color(.sRGB, red: 109/255, green: 109/255, blue: 109/255, opacity: 1.0), lineWidth: 1)
            )
            .cornerRadius(50)
        }
    }
