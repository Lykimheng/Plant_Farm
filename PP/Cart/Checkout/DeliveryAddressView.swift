//
//  DeliveryAddressView.swift
//  PP
//
//  Created by Ly Kimheng on 22/3/26.
//

import SwiftUI
import Combine

struct DeliveryAddressView: View {
    @Environment(\.dismiss) var dismiss
    @State private var isPayment = false
    @State private var user = ""
    @State private var phone = ""
    @State private var houseNumber = ""
    @State private var floor = ""

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(Color.black)
                        .font(.title2.bold())
                }
                
                Image("location")
                    .resizable()
                    .frame(width: 30, height: 30)
                
                Text("Delivery address")
                    .font(.title2.bold())
                
                Spacer()
            }
            .padding(20)

            // CONTENT
            ScrollView {
                VStack(spacing: 20){
                    DNameField(placeholder: "Name", text: $user)
                    DPhoneField(placeholder: "Phone number", text: $phone)
                    DHouseField(placeholder: "House Number", text: $houseNumber)
                    DFloorField(placeholder: "Floor", text: $floor)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 20)
            }
            
        
            Spacer()

            // CONTINUE BUTTON
            Button {
                isPayment = true
            } label: {
                Text("Continue to payment")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity) // Better than fixed 400
                    .frame(height: 50)
                    .background(Color(red: 32/255, green: 169/255, blue: 172/255))
                    .cornerRadius(10)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            
        }
        .preferredColorScheme(.light)
        // HIDE the system bar on THIS view to remove the "Space"
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(isPresented: $isPayment) {
            PaymentView()
                .toolbar(.hidden, for: .navigationBar)
        }
    }
}


#Preview {
    DeliveryAddressView()
}
