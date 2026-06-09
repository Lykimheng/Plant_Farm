//
//  OrderView.swift
//  PP
//
//  Created by Ly Kimheng on 8/6/26.
//

import SwiftUI

struct MyOrdersView: View {
    // sample orders — replace with real API data later
    let orders: [OrderModel] = [
        OrderModel(orderNumber: "PF-98234",
              date: "Oct 24, 2023 - 09:15 AM",
              status: .inTransit,
              items: [],
              total: 63.00,
              deliveryAddress: "No. 42, St. 271, Phnom Penh"),
        OrderModel(orderNumber: "PF-98100",
              date: "Oct 20, 2023 - 02:30 PM",
              status: .delivered,
              items: [],
              total: 35.00,
              deliveryAddress: "No. 42, St. 271, Phnom Penh"),
        OrderModel(orderNumber: "PF-97890",
              date: "Oct 15, 2023 - 11:00 AM",
              status: .cancelled,
              items: [],
              total: 28.00,
              deliveryAddress: "No. 42, St. 271, Phnom Penh"),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                if orders.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "bag")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.4))
                        Text("No orders yet")
                            .font(.title3)
                            .foregroundColor(.gray)
                        Text("Your orders will appear here after checkout")
                            .font(.caption)
                            .foregroundColor(.gray.opacity(0.7))
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    .padding(.top, 100)
                } else {
                    ForEach(orders) { order in
                        NavigationLink {
                            OrderDetailView()           // ← navigate to detail
                                .environmentObject(CartModel())
                                .environmentObject(LocationManager())
                        } label: {
                            OrderCard(order: order)     // ← show card
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(16)
        }
        .background(Color(.systemGray6))
        .navigationTitle("My Orders")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.light)
    }
}

#Preview {
    NavigationStack {
        MyOrdersView()
    }
}
