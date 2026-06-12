//
//  CheckoutView.swift
//  PP
//
//  Created by Ly Kimheng on 26/12/25.
//

import SwiftUI
import MapKit

struct DeliveryOptionRow: View {
    let option: (name: String, price: Double, duration: String)
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(option.name)
                    .font(.subheadline.bold())
                Text(String(format: "$%.2f", option.price))
                    .font(.title3.bold())
                Text(option.duration)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .gray)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                isSelected ?
                Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255) :
                Color.white
            )
            .foregroundColor(isSelected ? .white : .black)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255).opacity(0.3), lineWidth: 1)
            )
        }
    }
}

struct PaymentMethodRow: View {
    let method: (name: String, icon: String)    // ← same tuple type as your array
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255).opacity(0.1))
                        .frame(width: 44, height: 44)
                    Image(systemName: method.icon)
                        .foregroundColor(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255))
                }
                Text(method.name)
                    .font(.subheadline)
                    .foregroundColor(.black)
                Spacer()
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .foregroundColor(
                        isSelected ?
                        Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255) :
                        .gray.opacity(0.4)
                    )
                    .font(.title3)
            }
            .padding(.vertical, 14)
            .padding(.horizontal)
        }
    }
}

struct CheckoutView: View {
    @EnvironmentObject var cart: CartModel
    @EnvironmentObject var userData: UserModel
    @EnvironmentObject var location: LocationManager
    @EnvironmentObject var orders:  OrdersModel
    @State private var selectedDelivery = "Standard"
    @State private var specialNotes = ""
    @State private var selectedPayment = "ABA Pay"
    @State private var orderPlaced = false
    @State private var savedItems: [CartItem] = []
    let generatedOrderID = "PF-\(Int.random(in: 90000...99999))"
    
    
    private let deliveryOptions: [(name: String, price: Double, duration: String)] = [
        ("Standard", 1.50, "3-5 Days"),
        ("Express", 2.00, "Next Day")
    ]
    
    private let paymentMethods: [(name: String, icon: String)] = [
        ("ABA Pay", "building.columns"),
        ("KHQR", "qrcode"),
        ("Visa / Mastercard", "creditcard"),
        ("Cash on Delivery", "banknote")
    ]
    
    var deliveryFee: Double {
        selectedDelivery == "Standard" ? 1.50 : 2.00
    }
    
    var total: Double {
        cart.totalPrice + deliveryFee
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let coordinate = location.userLocation {
                               AppleMapView(coordinate: coordinate)   // ← real location
                                   .frame(height: 200)
                                   .cornerRadius(12)
                           } else {
                               // ← show while waiting for location
                               RoundedRectangle(cornerRadius: 12)
                                   .fill(Color(.systemGray5))
                                   .frame(height: 200)
                                   .overlay(
                                       VStack(spacing: 8) {
                                           ProgressView()
                                           Text("Getting your location...")
                                               .font(.caption)
                                               .foregroundColor(.gray)
                                       }
                                   )
                           }
                
                // MARK: - Delivery Address
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255))
                        Text("Delivery Address")
                            .font(.headline)
                            .foregroundColor(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255))
                        Spacer()
                        Button("Edit") {}
                            .foregroundColor(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255))
                    }
                    Text("Home")
                        .font(.subheadline.bold())
                    Text(location.userAddress)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    HStack(spacing: 4) {
                        Image(systemName: "phone")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("+123 456 789")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 4)

                // MARK: - Delivery Options
                VStack(alignment: .leading, spacing: 12) {
                    Text("Delivery Options")
                        .font(.headline)

                    HStack(spacing: 12) {
                        ForEach(deliveryOptions, id: \.name) { option in
                            DeliveryOptionRow(
                                option: option,
                                isSelected: selectedDelivery == option.name,
                                onTap: { selectedDelivery = option.name }
                            )
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 4)

                // MARK: - Special Notes
                VStack(alignment: .leading, spacing: 8) {
                    Text("Special Notes")
                        .font(.headline)

                    ZStack(alignment: .topLeading) {
                        if specialNotes.isEmpty {
                            Text("E.g. Please handle carefully, fragile plant...")
                                .foregroundColor(.gray.opacity(0.6))
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                        TextEditor(text: $specialNotes)
                            .frame(height: 100)
                            .opacity(specialNotes.isEmpty ? 0.25 : 1)
                    }
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 4)

                // MARK: - Payment Methods
                VStack(alignment: .leading, spacing: 12) {
                    Text("Payment Methods")
                        .font(.headline)

                    VStack(spacing: 0) {
                        ForEach(paymentMethods, id: \.name) { method in
                            PaymentMethodRow(
                                method: method,
                                isSelected: selectedPayment == method.name,
                                onTap: { selectedPayment = method.name }
                            )
                            if method.name != paymentMethods.last?.name {
                                Divider().padding(.leading, 74)
                            }
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 4)
                }

                // MARK: - Order Summary
                VStack(alignment: .leading, spacing: 12) {
                    Text("Order Summary")
                        .font(.headline.bold())
                        .foregroundColor(.white)

                    Divider()
                        .background(Color.white.opacity(0.3))

                    HStack {
                        Text("Subtotal")
                            .foregroundColor(.white.opacity(0.8))
                        Spacer()
                        Text(String(format: "$%.2f", cart.totalPrice))
                            .foregroundColor(.white)
                    }

                    HStack {
                        Text("Shipping Fee")
                            .foregroundColor(.white.opacity(0.8))
                        Spacer()
                        Text(String(format: "$%.2f", deliveryFee))
                            .foregroundColor(.white)
                    }

                    Divider()
                        .background(Color.white.opacity(0.3))

                    HStack {
                        Text("Total Amount")
                            .font(.headline.bold())
                            .foregroundColor(.white)
                        Spacer()
                        Text(String(format: "$%.2f", total))
                            .font(.title3.bold())
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .background(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255))
                .cornerRadius(12)

                // MARK: - Confirm Button
                Button {
                    savedItems = cart.items
                    
                    orders.addOrder(
                        orderNumber: generatedOrderID,
                        items: cart.items,
                        total: total,
                        deliveryAddress: location.userAddress
                    )
                    cart.clearCart()
                    orderPlaced = true
                } label: {
                    HStack {
                        Text("Confirm Order")
                            .font(.headline)
                        Image(systemName: "chevron.right")
                    }
                    .frame(maxWidth: .infinity, minHeight: 54)
                    .foregroundColor(.white)
                    .background(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255))
                    .cornerRadius(12)
                }
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
        .navigationDestination(isPresented: $orderPlaced) {
            OrderSuccessView(
                orderID: generatedOrderID,
                orderItems: savedItems,
                userEmail: userData.email
            )
            .environmentObject(cart)
        }
        .onAppear {
            location.requestPermission()
        }
        .background(Color(.systemGray6))
        .navigationTitle("Checkout")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.light)
    }
}

#Preview {
    NavigationStack {
        CheckoutView()
            .environmentObject(CartModel())
    }
}
