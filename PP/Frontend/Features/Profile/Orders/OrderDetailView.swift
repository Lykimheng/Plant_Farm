//
//  OrderDetailView.swift
//  PP
//
//  Created by Ly Kimheng on 8/6/26.
//

import SwiftUI

struct OrderDetailView: View {
    let order: OrderModel

    @EnvironmentObject private var orders: OrdersStore
    @EnvironmentObject private var location: LocationManager
    @EnvironmentObject private var user: UserStore

    @State private var showCancelAlert = false

    /// Always read the live copy so a cancel updates this screen immediately.
    private var current: OrderModel {
        orders.orders.first { $0.id == order.id } ?? order
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.lg) {
                statusHeader
                addressCard
                timeline
                itemsCard
                cancelSection
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.vertical, Theme.Spacing.lg)
            .readableWidth()
        }
        .background(Theme.background)
        .navigationTitle("Order #\(current.orderNumber)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .alert("Cancel this order?", isPresented: $showCancelAlert) {
            Button("Cancel order", role: .destructive) {
                Task { await orders.cancel(current, userId: user.id) }
            }
            Button("Keep order", role: .cancel) {}
        } message: {
            Text("Order #\(current.orderNumber) will be cancelled and won't be delivered.")
        }
    }

    // MARK: - Header

    private var statusHeader: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(headlineText)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(Theme.textPrimary)
                    Text("Placed \(current.dateText)")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.textSecondary)
                }
                Spacer()
                OrderStatusBadge(status: current.status, size: 12.5)
            }

            if let coordinate = location.userLocation, !current.status.isTerminated {
                AppleMapView(coordinate: coordinate)
                    .frame(height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous))
            }
        }
        .cardSurface(padding: Theme.Spacing.lg)
    }

    private var headlineText: String {
        switch current.status {
        case .pending:   return "Waiting for confirmation"
        case .confirmed: return "Confirmed"
        case .preparing: return "Being prepared"
        case .inTransit: return "On the way"
        case .delivered: return "Delivered"
        case .cancelled: return "Cancelled"
        case .rejected:  return "Rejected"
        }
    }

    // MARK: - Address

    private var addressCard: some View {
        SectionCard(title: "Delivery Address", icon: Icons.location) {
            Text(current.deliveryAddress.isBlank ? "No address recorded" : current.deliveryAddress)
                .font(.system(size: 14))
                .foregroundStyle(current.deliveryAddress.isBlank ? Theme.textTertiary : Theme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Timeline

    private var timeline: some View {
        SectionCard(title: "Progress", icon: "point.topleft.down.to.point.bottomright.curvepath") {
            VStack(spacing: 0) {
                ForEach(Array(steps.enumerated()), id: \.element.title) { index, step in
                    TimelineRow(
                        step: step,
                        isLast: index == steps.count - 1
                    )
                }
            }
        }
    }

    private struct Step {
        let title: String
        let subtitle: String
        let isDone: Bool
        let isCurrent: Bool
    }

    private var steps: [Step] {
        let status = current.status

        if status.isTerminated {
            return [
                Step(title: "Order placed", subtitle: current.dateText, isDone: true, isCurrent: false),
                Step(
                    title: status.label,
                    subtitle: "This order was \(status.label.lowercased()).",
                    isDone: false,
                    isCurrent: true
                )
            ]
        }

        let all = OrderModel.OrderStatus.fulfilmentSteps
        let currentIndex = all.firstIndex(of: status) ?? 0

        return all.enumerated().map { index, step in
            Step(
                title: step.label,
                subtitle: index < currentIndex ? "Done"
                        : index == currentIndex ? "In progress"
                        : "Upcoming",
                isDone: index < currentIndex,
                isCurrent: index == currentIndex
            )
        }
    }

    private struct TimelineRow: View {
        let step: Step
        let isLast: Bool

        var body: some View {
            HStack(alignment: .top, spacing: Theme.Spacing.md) {
                VStack(spacing: 0) {
                    ZStack {
                        Circle()
                            .fill(step.isDone ? Theme.brand : Theme.surfaceAlt)
                            .frame(width: 26, height: 26)
                            .overlay(
                                Circle().strokeBorder(step.isCurrent ? Theme.brand : .clear, lineWidth: 2)
                            )

                        if step.isDone {
                            Image(systemName: Icons.checkmark)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(Theme.onBrand)
                        } else if step.isCurrent {
                            Circle().fill(Theme.brand).frame(width: 9, height: 9)
                        }
                    }

                    if !isLast {
                        Rectangle()
                            .fill(step.isDone ? Theme.brand : Theme.separator)
                            .frame(width: 2, height: 30)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(step.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(step.isDone || step.isCurrent ? Theme.textPrimary : Theme.textTertiary)
                    Text(step.subtitle)
                        .font(.system(size: 11.5))
                        .foregroundStyle(Theme.textTertiary)
                }
                .padding(.top, 3)

                Spacer(minLength: 0)
            }
            .accessibilityElement(children: .combine)
        }
    }

    // MARK: - Items

    private var itemsCard: some View {
        SectionCard(title: "Items", icon: Icons.bag) {
            VStack(spacing: Theme.Spacing.md) {
                ForEach(current.items) { item in
                    HStack(spacing: Theme.Spacing.md) {
                        RemoteImage(urlString: item.plant.image)
                            .scaledToFill()
                            .frame(width: 56, height: 56)
                            .clipped()
                            .background(Theme.surfaceAlt)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.sm, style: .continuous))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.plant.name)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Theme.textPrimary)
                            Text("\(item.plant.price.priceText) × \(item.quantity)")
                                .font(.system(size: 11.5))
                                .foregroundStyle(Theme.textTertiary)
                        }

                        Spacer()

                        Text(item.lineTotal.priceText)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Theme.textPrimary)
                    }
                }

                Divider().overlay(Theme.separator)

                HStack {
                    Text("Total")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Theme.textPrimary)
                    Spacer()
                    Text(current.total.priceText)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(Theme.brand)
                }
            }
        } accessory: {
            Text("^[\(current.itemCount) item](inflect: true)")
                .font(.system(size: 12))
                .foregroundStyle(Theme.textTertiary)
        }
    }

    // MARK: - Cancel

    @ViewBuilder
    private var cancelSection: some View {
        if current.status.isCancellable {
            Button("Cancel order") { showCancelAlert = true }
                .buttonStyle(SecondaryButtonStyle(tint: Theme.danger))
        } else {
            Text(current.status.isTerminated
                 ? "This order was \(current.status.label.lowercased())."
                 : "This order is already being processed and can no longer be cancelled.")
                .font(.system(size: 12))
                .foregroundStyle(Theme.textTertiary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    NavigationStack {
        OrderDetailView(order: OrderModel(
            apiId: 1, orderNumber: "PF-98234", placedAt: Date(), status: .preparing,
            items: [CartItem(plant: .preview, quantity: 2)],
            total: 63, deliveryAddress: "No. 42, St. 271, Phnom Penh"
        ))
        .environmentObject(OrdersStore())
        .environmentObject(LocationManager())
        .environmentObject(UserStore())
    }
}
