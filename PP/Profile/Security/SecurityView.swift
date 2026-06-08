//
//  SecurityView.swift
//  PP
//
//  Created by Ly Kimheng on 26/12/25.
//

import SwiftUI

struct SecurityView: View {
    var body: some View {
        ZStack{
            LinearGradient(gradient: Gradient(colors: [.cyan ,.yellow, .purple, .blue]), startPoint: .top, endPoint: .bottom)
            Text("Security")
                .font(.largeTitle)
                .bold()
                .foregroundStyle(Color.white)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    SecurityView()
}
