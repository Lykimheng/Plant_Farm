//
//  SuccessView.swift
//  PP
//
//  Created by Ly Kimheng on 30/4/26.
//
import SwiftUI

struct OrderSuccessView: View {
    @EnvironmentObject var cart: CartModel
    @Environment(\.dismiss) private var dismiss
    let orderID: String
    let orderItems: [CartItem]
    let userEmail: String

    @State private var showTracking = false
    @State private var animateCheck = false
    @State private var animateContent = false

    var firstItemName: String {
        orderItems.first?.plant.name ?? "Plant"
    }

    var shipmentDescription: String {
        if orderItems.count == 1 {
            return firstItemName
        } else {
            return "\(firstItemName) & \(orderItems.count - 1) others"
        }
    }

    var body: some View {
        ZStack {
            // background gradient
            LinearGradient(
                colors: [
                    Color(.sRGB, red: 220/255, green: 250/255, blue: 255/255),
                    Color.white
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // decorative dots
            GeometryReader { geo in
                Group {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255))
                        .frame(width: 12, height: 12)
                        .rotationEffect(.degrees(45))
                        .position(x: geo.size.width * 0.1, y: geo.size.height * 0.15)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255))
                        .frame(width: 8, height: 8)
                        .rotationEffect(.degrees(45))
                        .position(x: geo.size.width * 0.85, y: geo.size.height * 0.12)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255).opacity(0.5))
                        .frame(width: 10, height: 10)
                        .rotationEffect(.degrees(45))
                        .position(x: geo.size.width * 0.9, y: geo.size.height * 0.22)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255).opacity(0.4))
                        .frame(width: 8, height: 8)
                        .rotationEffect(.degrees(45))
                        .position(x: geo.size.width * 0.08, y: geo.size.height * 0.28)
                }
            }

            ScrollView {
                VStack(spacing: 24) {

                    // MARK: - Success Icon
                    ZStack {
                        // outer ring
                        Circle()
                            .stroke(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255).opacity(0.2),
                                    lineWidth: 12)
                            .frame(width: 160, height: 160)

                        // filled circle
                        Circle()
                            .fill(Color(.sRGB, red: 171/255, green: 245/255, blue: 255/255))
                            .frame(width: 130, height: 130)

                        // checkmark
                        Image(systemName: "checkmark")
                            .font(.system(size: 55, weight: .bold))
                            .foregroundColor(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255))
                            .scaleEffect(animateCheck ? 1.0 : 0.3)
                            .opacity(animateCheck ? 1.0 : 0)
                    }
                    .padding(.top, 40)

                    // MARK: - Title
                    VStack(spacing: 8) {
                        Text("Order Placed Successfully")
                            .font(.title2.bold())
                            .foregroundColor(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255))
                            .multilineTextAlignment(.center)

                        Text("Your green companions are being\nprepared for their journey to your home.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 20)

                    // MARK: - Order Info Cards
                    VStack(spacing: 12) {
                        // Order ID
                        HStack(spacing: 16) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255))
                                    .frame(width: 44, height: 44)
                                Image(systemName: "number")
                                    .foregroundColor(.white)
                                    .font(.headline)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text("ORDER ID")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text("#\(orderID)")
                                    .font(.headline.bold())
                                    .foregroundColor(.black)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 4)

                        // Estimated Delivery
                        HStack(spacing: 16) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(.sRGB, red: 171/255, green: 245/255, blue: 255/255))
                                    .frame(width: 44, height: 44)
                                Image(systemName: "truck.box")
                                    .foregroundColor(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255))
                                    .font(.headline)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text("ESTIMATED DELIVERY")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text("2-3 Business Days")
                                    .font(.headline.bold())
                                    .foregroundColor(.black)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 4)

                        // Shipment info
                        HStack(spacing: 16) {
                            if let firstItem = orderItems.first {
                                Image(firstItem.plant.image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .cornerRadius(8)
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Shipment 1 of 1")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                                Text(shipmentDescription)
                                    .font(.subheadline.bold())
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white.opacity(0.2))
                        }
                        .padding()
                        .background(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255))
                        .cornerRadius(12)
                    }
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 20)

                    // MARK: - Buttons
                    VStack(spacing: 12) {
                        // Track Order
                        Button {
                            showTracking = true
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "dot.radiowaves.left.and.right")
                                Text("Track Order")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity, minHeight: 54)
                            .foregroundColor(.white)
                            .background(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255))
                            .cornerRadius(12)
                        }

                        // Continue Shopping
                        Button {
                            dismiss()              // ← go back to home
                        } label: {
                            Text("Continue Shopping")
                                .font(.headline)
                                .frame(maxWidth: .infinity, minHeight: 54)
                                .foregroundColor(.black)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                        }
                    }
                    .opacity(animateContent ? 1 : 0)

                    // confirmation email
                    Text("Confirmation email sent to\n\(userEmail)")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 30)
                        .opacity(animateContent ? 1 : 0)
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // animate checkmark first
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                animateCheck = true
            }
            // then animate content
            withAnimation(.easeOut(duration: 0.5).delay(0.5)) {
                animateContent = true
            }
        }
        .navigationDestination(isPresented: $showTracking) {
            OrderDetailView(order: OrderModel(
                orderNumber: orderID,
                date: "",
                status: .placed,
                items: orderItems,
                total: orderItems.reduce(0) { $0 + $1.plant.price * Double($1.quantity) },
                deliveryAddress: ""
            ))
            .environmentObject(LocationManager())
        }
        .preferredColorScheme(.light)
    }
}

//#Preview {
//    NavigationStack {
//        OrderSuccessView(orderID: "PF-98241", userEmail: "gardener@naturetech.com")
//            .environmentObject(CartModel())
//    }
//}
