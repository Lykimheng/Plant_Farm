//
//  MyOrders.swift
//  PP
//
//  Created by Ly Kimheng on 8/6/26.
//

import SwiftUI
import MapKit

struct OrderDetailView: View {
    let order: OrderModel
    @EnvironmentObject var orders: OrdersModel
    @EnvironmentObject var location: LocationManager
    @EnvironmentObject var user: UserModel
    @State private var showCancelAlert = false

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

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Estimated Arrival")
                            .font(.caption)
                            .foregroundColor(.gray.opacity(0.8))
                        Text("2:45 PM Today")
                            .font(.title3.bold())
                            .foregroundColor(.gray)
                    }
                    .padding()

                    HStack {
                        Spacer()
                        Text(order.status.rawValue)         // ← dynamic
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(order.status.color) // ← dynamic
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
                        Text(order.deliveryAddress)         // ← dynamic
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
                        ForEach(Array(orderStatuses(for: order.status).enumerated()), id: \.offset) { index, status in
                            HStack(alignment: .top, spacing: 16) {
                                VStack(spacing: 0) {
                                    ZStack {
                                        Circle()
                                            .fill(status.isDone ?
                                                Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255) :
                                                status.isCurrent ? Color.white : Color(.systemGray4))
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
                                    if index < orderStatuses(for: order.status).count - 1 {
                                        Rectangle()
                                            .fill(status.isDone ?
                                                Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255) :
                                                Color(.systemGray4))
                                            .frame(width: 2, height: 36)
                                    }
                                }
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(status.title)
                                        .font(.subheadline.bold())
                                        .foregroundColor(status.isDone || status.isCurrent ? .black : .gray)
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

                // MARK: - Courier (static for now)
                HStack(spacing: 16) {
                    Image("avatar")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Your Courier")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        Text("Sok San")
                            .font(.headline.bold())
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Button { } label: {
                        ZStack {
                            Circle().fill(Color.white.opacity(0.2)).frame(width: 44, height: 44)
                            Image(systemName: "message").foregroundColor(.white)
                        }
                    }
                    Button { } label: {
                        ZStack {
                            Circle().fill(Color.white.opacity(0.2)).frame(width: 44, height: 44)
                            Image(systemName: "phone").foregroundColor(.white)
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
                        Text("\(order.items.count) Items")    // ← dynamic
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }

                    ForEach(order.items) { item in            // ← dynamic
                        HStack(spacing: 12) {
                            Image(item.plant.image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 70, height: 70)
                                .cornerRadius(8)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.plant.name)
                                    .font(.subheadline.bold())
                                Text("Qty: \(item.quantity)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Text(String(format: "$%.2f", item.plant.price * Double(item.quantity)))
                                .font(.subheadline.bold())
                        }
                        if item.id != order.items.last?.id {
                            Divider()
                        }
                    }

                    Divider()

                    HStack {
                        Text("Total Amount")
                            .font(.headline.bold())
                        Spacer()
                        Text(String(format: "$%.2f", order.total))    // ← dynamic
                            .font(.headline.bold())
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 4)

                // MARK: - Cancel Button
                if order.status == .pending {
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
                } else {
                    Text(order.status == .cancelled ?
                         "This order has been cancelled." :
                         "Order already processed. Cannot be cancelled.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.bottom, 24)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
        .background(Color(.systemGray6))
        .navigationTitle("Order #\(order.orderNumber)")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.light)
        .alert("Cancel Order", isPresented: $showCancelAlert) {
            Button("Cancel Order", role: .destructive) {
                Task{
                    await orders.cancelOrder(order, userId: user.id)
                }

            }
            Button("Keep Order", role: .cancel) { }
        } message: {
            Text("Are you sure you want to cancel this order?")
        }
    }

    // ← generate status steps based on current order status
    func orderStatuses(for status: OrderModel.OrderStatus) -> [(title: String, subtitle: String, isDone: Bool, isCurrent: Bool)] {
        
        // ← handle cancelled/rejected separately
        if status == .cancelled || status == .rejected {
            return [
                (title: "Order Placed", subtitle: order.date, isDone: true, isCurrent: false),
                (title: status.rawValue, subtitle: "Order was \(status.rawValue.lowercased())", isDone: false, isCurrent: true)
            ]
        }

        let allStatuses: [OrderModel.OrderStatus] = [.pending, .confirmed, .preparing, .inTransit, .delivered]
        let currentIndex = allStatuses.firstIndex(of: status) ?? 0

        return allStatuses.map { s in
            let index = allStatuses.firstIndex(of: s) ?? 0
            return (
                title: s.rawValue,
                subtitle: index <= currentIndex ? order.date : "Pending",
                isDone: index < currentIndex,
                isCurrent: index == currentIndex
            )
        }
    }
}

#Preview {
    NavigationStack {
        OrderDetailView(order: OrderModel(
            orderNumber: "PF-98234",
            date: "Oct 24, 2023 - 09:15 AM",
            status: .preparing,
            items: [],
            total: 63.00,
            deliveryAddress: "No. 42, St. 271, Phnom Penh"
        ))
        .environmentObject(LocationManager())
        .environmentObject(OrdersModel())       // ← add this
    }
}
