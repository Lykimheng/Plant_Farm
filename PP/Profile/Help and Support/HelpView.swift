//
//  HelpView.swift
//  PP
//
//  Created by Ly Kimheng on 26/12/25.
//

import SwiftUI

struct HelpView: View {
    var body: some View {
        ZStack{
            LinearGradient(gradient: Gradient(colors: [.cyan ,.yellow, .purple, .blue]), startPoint: .top, endPoint: .bottom)
            Text("Help and Spport")
                .font(.largeTitle)
                .bold()
                .foregroundStyle(Color.white)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    HelpView()
}
