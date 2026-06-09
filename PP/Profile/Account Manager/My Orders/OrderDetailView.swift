//
//  MyOrders.swift
//  PP
//
//  Created by Ly Kimheng on 8/6/26.
//

import SwiftUI
import MapKit

struct OrderDetailView: View {
    @EnvironmentObject var cart: CartModel
    @EnvironmentObject var location: LocationManager
    @State private var showCancelAlert = false

    // sample order data — replace with real API data later
    let orderNumber = "PF-98234"
    let estimatedTime = "2:45 PM Today"
    let deliveryAddress = "No. 42, St. 271, Sangkat Tumnup Teuk, Phnom Penh, Cambodia"
    let courierName = "Sok San"
    let courierImage = "avatar"

    let orderStatuses: [(title: String, subtitle: String, isDone: Bool, isCurrent: Bool)] = [
        ("Order Placed", "Oct 24, 2023 - 09:15 AM", true, false),
        ("Payment Confirmed", "Oct 24, 2023 - 09:20 AM", true, false),
        ("Preparing Plant", "Quality check & hydration in progress", false, true),
        ("Out for Delivery", "Pending", false, false),
        ("Delivered", "Expected by 3:00 PM", false, false),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                // MARK: - Map
                ZStack(alignment: .bottomLeading) {
                    if let coordinate = location.userLocation {
                        AppleMapView(coordinate: coordinate)
                            .frame(height: 200)
                            .cornerRadius(16)
                    } else {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemGray5))
                            .frame(height: 200)
                            .overlay(ProgressView())
                    }

                    // estimated arrival overlay
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Estimated Arrival")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                        Text(estimatedTime)
                            .font(.title3.bold())
                            .foregroundColor(.white)
                    }
                    .padding()

                    // status badge
                    HStack {
                        Spacer()
                        Text("In Transit")
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255))
                            .cornerRadius(20)
                            .padding()
                    }
                }

                // MARK: - Delivery Address
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray6))
                            .frame(width: 40, height: 40)
                        Image(systemName: "mappin.circle")
                            .foregroundColor(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255))
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Delivery Address")
                            .font(.subheadline.bold())
                        Text(deliveryAddress)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 4)

                // MARK: - Order Status
                VStack(alignment: .leading, spacing: 16) {
                    Text("Order Status")
                        .font(.headline.bold())

                    VStack(spacing: 0) {
                        ForEach(Array(orderStatuses.enumerated()), id: \.offset) { index, status in
                            HStack(alignment: .top, spacing: 16) {

                                // timeline indicator
                                VStack(spacing: 0) {
                                    ZStack {
                                        Circle()
                                            .fill(status.isDone ?
                                                Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255) :
                                                status.isCurrent ?
                                                Color.white : Color(.systemGray4))
                                            .frame(width: 28, height: 28)
                                            .overlay(
                                                Circle()
                                                    .stroke(
                                                        status.isCurrent ?
                                                        Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255) :
                                                        Color.clear,
                                                        lineWidth: 2
                                                    )
                                            )

                                        if status.isDone {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundColor(.white)
                                        } else if status.isCurrent {
                                            Circle()
                                                .fill(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255))
                                                .frame(width: 10, height: 10)
                                        }
                                    }

                                    // connecting line
                                    if index < orderStatuses.count - 1 {
                                        Rectangle()
                                            .fill(status.isDone ?
                                                Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255) :
                                                Color(.systemGray4))
                                            .frame(width: 2, height: 36)
                                    }
                                }

                                // status text
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(status.title)
                                        .font(.subheadline.bold())
                                        .foregroundColor(
                                            status.isDone || status.isCurrent ? .black : .gray
                                        )
                                    Text(status.subtitle)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .padding(.top, 4)

                                Spacer()
                            }
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 4)

                // MARK: - Courier
                HStack(spacing: 16) {
                    Image(courierImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Your Courier")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        Text(courierName)
                            .font(.headline.bold())
                            .foregroundColor(.white)
                    }

                    Spacer()

                    // message button
                    Button { } label: {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 44, height: 44)
                            Image(systemName: "message")
                                .foregroundColor(.white)
                        }
                    }

                    // call button
                    Button { } label: {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 44, height: 44)
                            Image(systemName: "phone")
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding()
                .background(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255))
                .cornerRadius(12)

                // MARK: - Order Summary
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Order Summary")
                            .font(.headline.bold())
                        Spacer()
                        Text("\(cart.items.count) Items")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }

                    // items list
                    ForEach(cart.items) { item in
                        HStack(spacing: 12) {
                            Image(item.plant.image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 70, height: 70)
                                .cornerRadius(8)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.plant.name)
                                    .font(.subheadline.bold())
                                Text("Size: Medium | Qty: \(item.quantity)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }

                            Spacer()

                            Text(String(format: "$%.2f", item.plant.price * Double(item.quantity)))
                                .font(.subheadline.bold())
                        }

                        if item.id != cart.items.last?.id {
                            Divider()
                        }
                    }

                    Divider()

                    HStack {
                        Text("Total Amount")
                            .font(.headline.bold())
                        Spacer()
                        Text(String(format: "$%.2f", cart.totalPrice))
                            .font(.headline.bold())
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 4)

                // MARK: - Cancel Button
                Button {
                    showCancelAlert = true
                } label: {
                    Text("Cancel Order")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, minHeight: 54)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                }
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
        .background(Color(.systemGray6))
        .navigationTitle("Order #\(orderNumber)")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.light)
        .alert("Cancel Order", isPresented: $showCancelAlert) {
            Button("Cancel Order", role: .destructive) {
                // cancel order action
            }
            Button("Keep Order", role: .cancel) {}
        } message: {
            Text("Are you sure you want to cancel this order?")
        }
    }
}

#Preview {
    NavigationStack {
        OrderDetailView()
            .environmentObject(CartModel())
            .environmentObject(LocationManager())
    }
}
