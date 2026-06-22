//
//  PlantCircle.swift
//  PP
//
//  Created by Ly Kimheng on 24/12/25.
//

import SwiftUI

struct PlantCircle: View {
    let image: String
    let name: String

    var body: some View {
        VStack(spacing: 8) {
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .background(Color.white)
                .clipShape(Circle())

            Text(name)
                .font(.caption2)
                .foregroundColor(.white)
        }
    }
}

