//
//  CartView.swift
//  PP
//
//  Created by Ly Kimheng on 25/12/25.
//
import SwiftUI

struct CartView: View {
    @EnvironmentObject var cart: CartModel        // ← add this
    @State private var isCheckOut = false
    
    private let deliveryFee = 1.50
    
    var subtotal: Double {
        cart.totalPrice
    }
    
    var total: Double {
        subtotal + deliveryFee
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 2) {
                ScrollView(.vertical, showsIndicators: false) {
                    if cart.items.isEmpty {
                        // ← show empty state
                        VStack(spacing: 16) {
                            Image(systemName: "cart")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            Text("Your cart is empty")
                                .font(.title3)
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 100)
                    } else {
                        ForEach(cart.items) { item in
                            ProductCard(
                                image: item.plant.image,
                                productName: item.plant.name,
                                price: String(format: "%.2f", item.plant.price),
                                quantity: item.quantity,
                                onIncrease: { cart.increase(plant: item.plant) },
                                onDecrease: { cart.decrease(plant: item.plant) },
                                onDelete: { cart.removeItem(plant: item.plant) }
                            )
                        }
                    }
                }
                
                // Summary section
                VStack(spacing: 20) {
                    HStack {
                        Text("Subtotal")
                            .font(.system(size: 15))
                            .foregroundStyle(Color.gray)
                        Spacer()
                        Text(String(format: "$%.2f", subtotal))    // ← dynamic
                            .font(.system(size: 15))
                            .foregroundStyle(Color.black.opacity(0.6))
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                    
                    HStack {
                        Text("Standard delivery")
                            .font(.system(size: 15))
                            .foregroundStyle(Color.black.opacity(0.6))
                        Spacer()
                        Text(String(format: "$%.2f", deliveryFee))
                            .font(.system(size: 15))
                            .foregroundStyle(Color.black.opacity(0.6))
                    }
                    .padding(.horizontal, 20)
                    
                    Divider()
                        .frame(height: 5)
                        .background(Color.white)
                    
                    HStack {
                        Text("Total amount")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(Color.black)
                        Spacer()
                        Text(String(format: "$%.2f", total))       // ← dynamic
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(Color.black)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                .background(Color.white)
                
                Spacer()
                
                Button {
                    isCheckOut = true
                } label: {
                    Text("Checkout")
                        .font(.system(size: 20))
                        .padding()
                        .foregroundColor(.white)
                        .frame(width: 400, height: 50)
                        .background(cart.items.isEmpty ?    // ← disable if empty
                            Color.gray :
                            Color(.sRGB, red: 32/255, green: 169/255, blue: 172/255))
                        .cornerRadius(10)
                }
                .disabled(cart.items.isEmpty)              // ← can't checkout if empty
                .padding(.top, 10)
                .padding(.bottom, 50)
                .frame(maxWidth: .infinity)
            }
            .background(Color(.systemGray6))
            .preferredColorScheme(.light)
            .navigationDestination(isPresented: $isCheckOut) {
                CheckoutView()
                    .navigationTitle("Checkout")
                    .toolbar(.hidden, for: .tabBar)
            }
        }
    }
}
#Preview{
    CartView()
}
