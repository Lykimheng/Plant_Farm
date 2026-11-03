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

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.lg) {
                amountCard
                methods
                InlineError(message: viewModel.message)
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

    // MARK: - Amount

    private var amountCard: some View {
        VStack(spacing: 4) {
            Text("Amount to pay")
                .font(.system(size: 12.5, weight: .medium))
                .foregroundStyle(Theme.textSecondary)
            Text(viewModel.amount.priceText)
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(Theme.textPrimary)
            Text("Order #\(viewModel.order.orderNumber)")
                .font(.system(size: 12))
                .foregroundStyle(Theme.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .cardSurface(padding: Theme.Spacing.lg)
    }

    // MARK: - Methods

    private var methods: some View {
        SectionCard(title: "Pay with", icon: Icons.card) {
            VStack(spacing: 0) {
                ForEach(PaymentMethod.online) { method in
                    PaymentMethodRow(method: method, isSelected: viewModel.method == method) {
                        Task { await viewModel.choose(method, using: orders) }
                    }
                    .disabled(viewModel.isBusy)

                    if viewModel.method == method {
                        expanded(for: method)
                            .padding(.bottom, Theme.Spacing.md)
                    }

                    if method != PaymentMethod.online.last {
                        Divider().overlay(Theme.separator).padding(.leading, 56)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func expanded(for method: PaymentMethod) -> some View {
        switch viewModel.phase {
        case .starting:
            HStack(spacing: Theme.Spacing.sm) {
                ProgressView()
                Text("Connecting to ABA PayWay…")
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.md)
        case .waiting:
            if method == .aba {
                bankAppSection
            } else if method == .card {
                cardSection
            } else {
                qrSection
            }
        case .paid, .stopped:
            EmptyView()
        }
    }

    private var bankAppSection: some View {
        VStack(spacing: Theme.Spacing.md) {
            note(viewModel.isBankAppMissing
                 ? "ABA Mobile didn't open on this phone. Scan or save the KHQR code below instead."
                 : "Confirm the payment in ABA Mobile, then come back here. This screen updates as soon as ABA confirms it.")

            if !viewModel.isBankAppMissing {
                Button("Open ABA Mobile") {
                    Task { await viewModel.openBankApp() }
                }
                .buttonStyle(.primary)
            }

            if viewModel.showsQRForBankApp {
                qrSection
            } else {
                Button("Show KHQR code instead") { viewModel.showsQRForBankApp = true }
                    .font(.system(size: 13.5, weight: .semibold))
                    .foregroundStyle(Theme.brand)
            }
        }
    }

    @ViewBuilder
    private var qrSection: some View {
        if let qr = viewModel.session?.qrString {
            VStack(spacing: Theme.Spacing.md) {
                KHQRCard(qrString: qr, amount: viewModel.amount)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(Theme.separator, lineWidth: 0.7)
                    )

                if let snapshot = viewModel.qrSnapshot {
                    HStack(spacing: Theme.Spacing.md) {
                        Button {
                            save(snapshot)
                        } label: {
                            Label("Save to Photos", systemImage: "square.and.arrow.down")
                        }
                        .buttonStyle(.secondary)

                        ShareLink(
                            item: Image(uiImage: snapshot),
                            preview: SharePreview(Text(verbatim: "KHQR"), image: Image(uiImage: snapshot))
                        ) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        .buttonStyle(.secondary)
                    }
                }

                note("Scan it with ABA Mobile or any KHQR bank app. Paying on this phone? Save it, then in your bank app tap Scan and choose the image from your photos.")
            }
        }
    }

    private var cardSection: some View {
        VStack(spacing: Theme.Spacing.md) {
            note("You'll type your card number, expiry date and CVV on ABA PayWay's secure form. Plant Farm never sees your card details.")

            Button("Enter card details") { viewModel.showsCardForm = true }
                .buttonStyle(.primary)
                .disabled(viewModel.cardForm == nil)
        }
    }

    private func note(_ text: LocalizedStringResource) -> some View {
        Text(text)
            .font(.system(size: 12.5))
            .foregroundStyle(Theme.textSecondary)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity)
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
                paymentMethod: .khqr
            ),
            onPaid: { _ in },
            onLater: {}
        )
        .environmentObject(OrdersStore())
        .environmentObject(ToastCenter())
    }
}
