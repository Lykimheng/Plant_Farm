//
//  PaymentView.swift
//  PP
//
//  Created by Ly Kimheng on 22/3/26.
//

import SwiftUI

struct PaymentView: View {
    @State private var isChecked: Bool = false
    @State private var isChecked2: Bool = false
    @State private var isChecked3: Bool = false
    @State private var isPayment: Bool = false
    
    
    var body: some View {
        NavigationStack{
            VStack{
                HStack{
                    Button{
                        
                    }label: {
                        Image(systemName: Constants.backIcon)
                            .foregroundColor(Color.primary)
                            .font(.title2)
                    }
                    Spacer()
                    Text("Payment")
                        .fontWeight(.bold)
                        .font(.title2)
                    Spacer()
                    Text("    ")
                    
                }
                .padding(.horizontal)
                Spacer()
                VStack(alignment: .leading){
                    Text("Choose a payment method")
                        .font(.title3.bold())
                    
                    HStack{
                        Button(action: { isChecked.toggle() }) {
                            Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(Color.gray)
                        }
                        
                        Image("ABA")
                            .frame(width: 120, height: 80)
                        Spacer()
                        Text("ABA Pay")
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding()
                    .frame(width: 400 ,height: 80)
                    .background(Color.white.opacity(0.9))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.sRGB, red: 32/255, green: 169/255, blue: 172/255, opacity: 1.0), lineWidth: 3)
                    )
                    .cornerRadius(12)
                    
                    HStack{
                        Button(action: { isChecked.toggle() }) {
                            Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(Color.gray)
                        }
                        
                        Image("Wing")
                            .frame(width: 120, height: 80)
                        Spacer()
                        Text("Wing Bank")
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding()
                    .frame(width: 400 ,height: 80)
                    .background(Color.white.opacity(0.9))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.sRGB, red: 32/255, green: 169/255, blue: 172/255, opacity: 1.0), lineWidth: 3)
                    )
                    .cornerRadius(12)
                    
                    HStack{
                        Button(action: { isChecked.toggle() }) {
                            Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(Color.gray)
                        }
                        VStack(spacing: 4){
                            Spacer()
                            Text("Credit or Debit Card")
                                .fontWeight(.bold)
                            HStack{
                                Image("Visa 1")
                                    .frame(width: 30, height: 20)
                                Image("MasterCard 1")
                                    .frame(width: 30, height: 20)
                            }
                            Spacer()
                        }
                        .frame(width: 200, height: 80)
                        Spacer()
                    }
                    .padding()
                    .frame(width: 400 ,height: 80)
                    .background(Color.white.opacity(0.9))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.sRGB, red: 32/255, green: 169/255, blue: 172/255, opacity: 1.0), lineWidth: 3)
                    )
                    .cornerRadius(12)
                    
                    
                    Button {
                        isPayment = true
                    } label: {
                        Text("Pay")
                            .frame(width: 400, height: 50)
                            .foregroundColor(.white)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(.sRGB, red: 32/255, green: 169/255, blue: 172/255, opacity: 1.0))
                            )
                    }
                    .padding(.top, 50)
                    Spacer()
                }
                .padding(.top)
                
            }
            .preferredColorScheme(.light)
            .navigationDestination(isPresented: $isPayment){
                SuccessView()
                    .toolbar(.hidden)
            }
        }
    }
}
#Preview {
    PaymentView()
}
