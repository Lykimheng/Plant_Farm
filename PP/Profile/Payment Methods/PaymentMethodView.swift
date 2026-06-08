//
//  PaymentView.swift
//  PP
//
//  Created by Ly Kimheng on 26/12/25.
//

import SwiftUI

struct PaymentMethodView: View {
    var body: some View {
        ZStack{
            LinearGradient(gradient: Gradient(colors: [.cyan ,.yellow, .purple, .blue]), startPoint: .top, endPoint: .bottom)
            Text("Payment Methods")
                .font(.largeTitle)
                .bold()
                .foregroundStyle(Color.white)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    PaymentMethodView()
}
