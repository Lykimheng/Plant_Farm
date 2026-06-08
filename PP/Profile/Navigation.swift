//
//  NavigationView.swift
//  PP
//
//  Created by Ly Kimheng on 26/12/25.
//

import SwiftUI
import UIColorHexSwift

struct Navigation: View {
    let image1: String
    let name: String
    let greenColor = UIColor("#20A9AC").cgColor
    var body: some View {
        
        Button(action: {
        }) {
            HStack(spacing: 12) {
                Image(systemName: image1)

                Text(name)
                    .font(.system(size: 20, weight: .regular))

                Spacer()

                Image(systemName: Constants.seeMoreIcon)
            }
            .foregroundColor(.white)
            .padding(.horizontal,)
            .frame(height: 50)
            .background(Color(.sRGB, red: 32/255, green: 169/255, blue: 172/255, opacity: 1.0) )
            .cornerRadius(10)
        }
        .padding(.horizontal, 10)
    }
}

#Preview {
    Navigation(image1: Constants.notificationIcon, name: "Notifaction")
}
