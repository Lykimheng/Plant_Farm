//
//  MyOrdersView.swift
//  PP
//
//  Created by Ly Kimheng on 26/12/25.
//

import SwiftUI

struct MyOrdersView: View {
    @EnvironmentObject private var orders: OrdersStore
    @EnvironmentObject private var user: UserStore

    var body: some View {
        Group {
            if orders.isLoading && orders.orders.isEmpty {
                SkeletonList(count: 3, height: 132)
                    .padding(Theme.Spacing.lg)
            } else if orders.orders.isEmpty {
                EmptyStateView(
                    icon: Icons.bag,
                    title: "No orders yet",
                    message: "Orders you place will appear here with live delivery status."
                )
                .frame(maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: Theme.Spacing.md) {
                        ForEach(orders.orders) { order in
                            NavigationLink {
                                OrderDetailView(order: order)
                            } label: {
                                OrderCard(order: order)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(Theme.Spacing.lg)
                    .readableWidth()
                }
                .refreshable { await orders.load(userId: user.id) }
            }
        }
        .background(Theme.background)
        .navigationTitle("My Orders")
        .navigationBarTitleDisplayMode(.inline)
        .task { await orders.load(userId: user.id) }
    }
}

#Preview {
    NavigationStack {
        MyOrdersView()
            .environmentObject(OrdersStore())
            .environmentObject(UserStore())
            .environmentObject(LocationManager())
    }
}
