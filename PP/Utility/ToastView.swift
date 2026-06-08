//
//  ToastView.swift
//  PP
//
//  Created by Ly Kimheng on 29/5/26.
//

import SwiftUI

struct ToastView: View {
    let message: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "cart.badge.plus")
                .foregroundColor(.white)
                .font(.title3)
            Text(message)
                .foregroundColor(.white)
                .font(.subheadline.bold())
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(Color(.sRGB, red: 32/255, green: 169/255, blue: 172/255))
                .shadow(radius: 10)
        )
    }
}

