//
//  PaymentView.swift
//  PP
//
//  Created by Ly Kimheng on 3/11/26.
//

import SwiftUI

struct PaymentView: View {
    @StateObject private var viewModel: PaymentViewModel
    @EnvironmentObject private var orders: OrdersStore
    @EnvironmentObject private var toast: ToastCenter
    @Environment(\.scenePhase) private var scenePhase

    @State private var showCancelAlert = false
    @State private var showPhotoSettings = false

    private let onPaid: (OrderModel) -> Void
    private let onLater: () -> Void

    init(order: OrderModel, onPaid: @escaping (OrderModel) -> Void, onLater: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: PaymentViewModel(order: order))
        self.onPaid = onPaid
        self.onLater = onLater
    }

    private var otherMethod: PaymentMethod {
        viewModel.method == .abaKHQR ? .card : .abaKHQR
    }

    private var subtotal: Double {
        viewModel.order.items.reduce(0) { $0 + $1.lineTotal }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.lg) {
                merchantHeader
                paymentContent
                InlineError(message: viewModel.message)
                totals

                if viewModel.isWaiting || viewModel.phase == .stopped {
                    Button {
                        Task { await viewModel.choose(otherMethod, using: orders) }
                    } label: {
                        Text("Pay with \(Text(otherMethod.name)) instead")
                    }
                    .font(.system(size: 13.5, weight: .semibold))
                    .foregroundStyle(Theme.brand)
                    .disabled(viewModel.isBusy)
                }
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.vertical, Theme.Spacing.lg)
            .readableWidth()
            .animation(.easeInOut(duration: 0.2), value: viewModel.phase)
        }
        .background(Theme.background)
        .safeAreaInset(edge: .bottom) { bottomBar }
        .navigationTitle("Payment")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Pay later", action: onLater)
            }
        }
        .task { await viewModel.startIfNeeded(using: orders) }
        .task(id: viewModel.isWaiting) { await viewModel.poll(using: orders) }
        .task(id: viewModel.session?.tranId) { await viewModel.watchExpiry(using: orders) }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { Task { await viewModel.refresh(using: orders) } }
        }
        .onOpenURL { url in
            guard url.scheme == "plantfarm" else { return }
            Task { await viewModel.refresh(using: orders) }
        }
        .onChange(of: viewModel.phase) { _, phase in
            if phase == .paid { onPaid(orders.latest(viewModel.order)) }
        }
        .sheet(isPresented: $viewModel.showsCardForm, onDismiss: {
            Task { await viewModel.cardFormClosed(using: orders) }
        }) {
            if let form = viewModel.cardForm {
                PayWayCardSheet(form: form, amount: viewModel.amount)
            }
        }
        .alert("Cancel this payment?", isPresented: $showCancelAlert) {
            Button("Cancel payment", role: .destructive) {
                Task { await viewModel.cancel(using: orders) }
            }
            Button("Keep paying", role: .cancel) {}
        } message: {
            Text("Your order stays saved but unpaid. You can pay for it later from My Orders.")
        }
        .alert("Allow saving to Photos", isPresented: $showPhotoSettings) {
            Button("Open Settings") {
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(url)
            }
            Button("Not now", role: .cancel) {}
        } message: {
            Text("Plant Farm can't add photos right now. In Settings, tap Photos and allow Plant Farm to add photos so you can save the KHQR code.")
        }
    }

    // MARK: - Header

    private var merchantHeader: some View {
        VStack(spacing: Theme.Spacing.xs) {
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(height: 60)
                .accessibilityLabel(Text(verbatim: "Plant Farm"))
            Text("Order #\(viewModel.order.orderNumber)")
                .font(.system(size: 12))
                .foregroundStyle(Theme.textTertiary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Content

    @ViewBuilder
    private var paymentContent: some View {
        switch viewModel.phase {
        case .starting:
            HStack(spacing: Theme.Spacing.sm) {
                ProgressView()
                Text("Connecting to ABA PayWay…")
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.xl)
        case .waiting:
            if viewModel.method == .card {
                cardSection
            } else {
                qrSection
            }
        case .paid, .stopped:
            HStack(spacing: Theme.Spacing.md) {
                PaymentMethodIcon(method: viewModel.method)
                Text(viewModel.method.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Theme.textPrimary)
                Spacer(minLength: 0)
            }
            .cardSurface(padding: Theme.Spacing.md)
        }
    }

    @ViewBuilder
    private var qrSection: some View {
        if let qr = viewModel.session?.qrString {
            VStack(spacing: Theme.Spacing.sm) {
                if viewModel.canOpenBankApp {
                    Button("Open ABA Mobile") {
                        Task { await viewModel.openBankApp() }
                    }
                    .buttonStyle(.primary)
                    .padding(.bottom, Theme.Spacing.sm)
                }

                KHQRCard(qrString: qr, amount: viewModel.amount)
                    .softShadow()
                    .padding(.bottom, Theme.Spacing.sm)

                Text("Scan to Pay")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)

                Text("or")
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.textSecondary)

                if let snapshot = viewModel.qrSnapshot {
                    Button {
                        save(snapshot)
                    } label: {
                        Label("Download QR", systemImage: "square.and.arrow.down")
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.brand)
                }

                Text("and upload to Mobile Banking app supporting KHQR")
                    .font(.system(size: 12.5))
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var cardSection: some View {
        VStack(spacing: Theme.Spacing.md) {
            HStack(spacing: Theme.Spacing.md) {
                PaymentMethodIcon(method: .card)
                PaymentBrandMarks()
                Spacer(minLength: 0)
            }

            Text("You'll type your card number, expiry date and CVV on ABA PayWay's secure form. Plant Farm never sees your card details.")
                .font(.system(size: 12.5))
                .foregroundStyle(Theme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button("Enter card details") { viewModel.showsCardForm = true }
                .buttonStyle(.primary)
                .disabled(viewModel.cardForm == nil)
        }
        .cardSurface(padding: Theme.Spacing.lg)
    }

    // MARK: - Totals

    private var totals: some View {
        VStack(spacing: Theme.Spacing.sm) {
            totalRow(Text("Subtotal"), subtotal)
            totalRow(Text("Delivery"), max(0, viewModel.amount - subtotal))

            Divider().overlay(Theme.separator)

            HStack {
                Text("Total")
                Spacer()
                Text(viewModel.amount.priceText)
            }
            .font(.system(size: 15, weight: .bold))
            .foregroundStyle(Theme.textPrimary)
        }
        .padding(.horizontal, Theme.Spacing.xs)
    }

    private func totalRow(_ label: Text, _ value: Double) -> some View {
        HStack {
            label
            Spacer()
            Text(value.priceText)
        }
        .font(.system(size: 13))
        .foregroundStyle(Theme.textSecondary)
    }

    // MARK: - Bottom bar

    private var bottomBar: some View {
        VStack(spacing: Theme.Spacing.sm) {
            switch viewModel.phase {
            case .starting, .waiting:
                waitingStatus

                Button("Cancel payment", role: .destructive) { showCancelAlert = true }
                    .buttonStyle(SecondaryButtonStyle(tint: Theme.danger))
                    .disabled(!viewModel.isWaiting || viewModel.isBusy)
            case .stopped:
                Button("Try again") {
                    Task { await viewModel.retry(using: orders) }
                }
                .buttonStyle(.primary)

                Button("Pay later", action: onLater)
                    .buttonStyle(.secondary)
            case .paid:
                ProgressView()
                    .frame(height: Theme.Size.control)
            }
        }
        .padding(Theme.Spacing.lg)
        .readableWidth()
        .background(.regularMaterial)
        .overlay(alignment: .top) {
            Rectangle().fill(Theme.separator).frame(height: 0.7)
        }
    }

    private var waitingStatus: some View {
        HStack(spacing: Theme.Spacing.sm) {
            ProgressView()
                .controlSize(.small)
            Text("Waiting for your payment…")
            Spacer(minLength: 0)
            if let expiresAt = viewModel.session?.expiresAt, expiresAt > .now {
                Text(timerInterval: Date.now...expiresAt, countsDown: true)
                    .monospacedDigit()
                    .foregroundStyle(Theme.textTertiary)
            }
        }
        .font(.system(size: 12.5, weight: .medium))
        .foregroundStyle(Theme.textSecondary)
        .opacity(viewModel.isWaiting ? 1 : 0)
    }

    private func save(_ image: UIImage) {
        Task {
            do {
                try await PhotoLibrarySaver.save(image)
                toast.show("KHQR code saved to Photos")
            } catch PhotoLibrarySaver.Failure.accessDenied {
                showPhotoSettings = true
            } catch {
                toast.show("Couldn't save the KHQR code. Please try again.")
            }
        }
    }
}

#Preview {
    NavigationStack {
        PaymentView(
            order: OrderModel(
                apiId: 1,
                orderNumber: "PF-98241",
                placedAt: Date(),
                status: .pending,
                items: [CartItem(plant: .preview, quantity: 2)],
                total: 37.50,
                deliveryAddress: "No. 42, St. 271, Phnom Penh",
                paymentMethod: .abaKHQR
            ),
            onPaid: { _ in },
            onLater: {}
        )
        .environmentObject(OrdersStore())
        .environmentObject(ToastCenter())
    }
}
