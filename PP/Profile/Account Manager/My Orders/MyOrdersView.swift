//
//  OrderView.swift
//  PP
//
//  Created by Ly Kimheng on 8/6/26.
//

import SwiftUI

struct MyOrdersView: View {
    @EnvironmentObject var cart: CartModel
    @EnvironmentObject var orders: OrdersModel
    @EnvironmentObject var location: LocationManager
    @EnvironmentObject var user: UserModel
    var body: some View {
        Group {
            if orders.isLoading && orders.orders.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGray6))
            } else if orders.orders.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: Constants.notificationIcon)
                        .font(.system(size: 60))
                        .foregroundColor(.gray.opacity(0.4))
                    Text("No orders yet")
                        .font(.title3)
                        .foregroundColor(.gray)
                    Text("Your orders will appear here after checkout")
                        .font(.caption)
                        .foregroundColor(.gray.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGray6))
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(orders.orders) { order in
                            NavigationLink {
                                OrderDetailView(order: order)
                            } label: {
                                OrderCard(order: order)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(16)
                }
                .background(Color(.systemGray6))
            }
        }
        .navigationTitle("My Orders")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.light)
        .onAppear {
            Task {
                await orders.fetchOrders(userId: user.id)
            }
        }
    }
}

#Preview {
    NavigationStack {
        MyOrdersView()
            .environmentObject(CartModel())
            .environmentObject(LocationManager())
    }
}
