//
//  PaymentViewModel.swift
//  PP
//
//  Created by Ly Kimheng on 3/11/26.
//

import SwiftUI
import Combine

// The server decides whether the order is paid, from ABA PayWay's own answer;
// this only asks it, every few seconds and whenever the customer comes back.
@MainActor
final class PaymentViewModel: ObservableObject {
    enum Phase {
        case starting, waiting, paid, stopped
    }

    @Published private(set) var method: PaymentMethod
    @Published private(set) var session: PaymentSession?
    @Published private(set) var phase: Phase = .starting
    @Published private(set) var message: LocalizedStringResource?
    @Published private(set) var isBusy = false
    @Published private(set) var canOpenBankApp = false
    @Published private(set) var qrSnapshot: UIImage?
    // only the response that opens a card attempt carries PayWay's form
    @Published private(set) var cardForm: PaymentSession.CardForm?
    @Published var showsCardForm = false

    let order: OrderModel
    private var hasStarted = false

    init(order: OrderModel) {
        self.order = order
        method = order.paymentMethod.paysOnline ? order.paymentMethod : .abaKHQR
    }

    var isWaiting: Bool { phase == .waiting }

    var amount: Double { session?.amount ?? order.total }

    func startIfNeeded(using orders: OrdersStore) async {
        guard !hasStarted else { return }
        hasStarted = true
        await begin(method, using: orders)
    }

    func choose(_ method: PaymentMethod, using orders: OrdersStore) async {
        guard method != self.method || phase == .stopped else { return }
        await begin(method, using: orders)
    }

    func retry(using orders: OrdersStore) async {
        await begin(method, using: orders)
    }

    func openBankApp() async {
        guard let link = session?.deeplink else { return }
        await UIApplication.shared.open(link)
    }

    func refresh(using orders: OrdersStore) async {
        guard phase == .waiting, !isBusy else { return }
        let attempt = session?.tranId

        do {
            let update = try await orders.refreshPayment(for: order)
            // a cancel or a new attempt may have finished while this was in flight
            guard phase == .waiting, !isBusy, session?.tranId == attempt else { return }
            apply(update)
        } catch {
            AppLog.network("check payment", error)
        }
    }

    func poll(using orders: OrdersStore) async {
        while phase == .waiting, !Task.isCancelled {
            try? await Task.sleep(for: .seconds(3))
            guard !Task.isCancelled else { return }
            await refresh(using: orders)
        }
    }

    func watchExpiry(using orders: OrdersStore) async {
        guard let expiresAt = session?.expiresAt, phase == .waiting else { return }

        let remaining = expiresAt.timeIntervalSinceNow
        if remaining > 0 {
            try? await Task.sleep(for: .seconds(remaining))
        }
        guard !Task.isCancelled else { return }

        await refresh(using: orders)
        if phase == .waiting {
            stop("The payment time ran out. Your order is saved but not paid. Tap Try again for a new code.")
        }
    }

    func cancel(using orders: OrdersStore) async {
        guard phase == .waiting, !isBusy else { return }
        isBusy = true
        defer { isBusy = false }

        do {
            apply(try await orders.cancelPayment(for: order))
        } catch {
            message = error.userMessage
            AppLog.network("cancel payment", error)
        }
    }

    // PayWay's card form works once, so closing it ends that attempt
    func cardFormClosed(using orders: OrdersStore) async {
        guard phase == .waiting, method == .card else { return }
        await refresh(using: orders)
        await cancel(using: orders)
    }

    // MARK: - Private

    private func begin(_ method: PaymentMethod, using orders: OrdersStore) async {
        guard !isBusy else { return }
        isBusy = true
        self.method = method
        phase = .starting
        message = nil
        session = nil
        qrSnapshot = nil
        cardForm = nil
        canOpenBankApp = false

        do {
            apply(try await orders.startPayment(for: order, method: method))
            cardForm = session?.cardForm
        } catch {
            phase = .stopped
            message = error.userMessage
            AppLog.network("start payment", error)
        }
        isBusy = false

        guard phase == .waiting else { return }

        if method == .card {
            showsCardForm = cardForm != nil
        } else if let link = session?.deeplink, UIApplication.shared.canOpenURL(link) {
            // ABA KHQR: straight to ABA Mobile when it's there, the code stays on screen either way
            canOpenBankApp = true
            await openBankApp()
        }
    }

    private func apply(_ update: PaymentUpdate) {
        if update.isPaid {
            phase = .paid
            showsCardForm = false
            return
        }

        if update.session?.tranId != session?.tranId {
            qrSnapshot = update.session?.qrString.flatMap { qr in
                KHQRCard(qrString: qr, amount: update.session?.amount ?? order.total).snapshot()
            }
        }
        session = update.session

        switch update.session?.status {
        case .pending:
            phase = .waiting
        case .approved:
            phase = .paid
        case .declined:
            stop("Your bank declined the payment. Your order is saved but not paid. Try again or choose another way to pay.")
        case .cancelled:
            stop("Payment cancelled. Your order is saved but not paid.")
        case .expired:
            stop("The payment time ran out. Your order is saved but not paid. Tap Try again for a new code.")
        case .refunded, .failed, nil:
            stop("The payment didn't go through. Your order is saved but not paid. Try again or choose another way to pay.")
        }
    }

    private func stop(_ reason: LocalizedStringResource) {
        phase = .stopped
        message = reason
        showsCardForm = false
    }
}
