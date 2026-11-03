//
//  PayWayCardSheet.swift
//  PP
//
//  Created by Ly Kimheng on 3/11/26.
//

import SwiftUI
import WebKit

// ABA PayWay's own card form: card details go straight to the bank, never through Plant Farm
struct PayWayCardSheet: View {
    let form: PaymentSession.CardForm
    let amount: Double

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            PayWayWebView(form: form)
                .ignoresSafeArea(edges: .bottom)
                .safeAreaInset(edge: .top, spacing: 0) { secureNote }
                .navigationTitle("Card payment")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") { dismiss() }
                    }
                }
        }
    }

    private var secureNote: some View {
        HStack(spacing: Theme.Spacing.sm) {
            Image(systemName: "lock.shield")
                .foregroundStyle(Theme.success)
            Text("Secured by ABA PayWay · \(amount.priceText)")
                .foregroundStyle(Theme.textSecondary)
            Spacer(minLength: 0)
        }
        .font(.system(size: 12.5, weight: .medium))
        .padding(.horizontal, Theme.Spacing.lg)
        .padding(.vertical, Theme.Spacing.sm)
        .background(Theme.surfaceAlt)
    }
}

private struct PayWayWebView: UIViewRepresentable {
    let form: PaymentSession.CardForm

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.loadHTMLString(form.html, baseURL: form.baseURL)
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}

    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        private static let webSchemes: Set<String> = ["http", "https", "about", "data", "blob", "javascript"]

        // bank-app and return links (abamobilebank://, plantfarm://) leave the form
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
            guard let url = navigationAction.request.url,
                  let scheme = url.scheme?.lowercased(),
                  !Self.webSchemes.contains(scheme) else { return .allow }

            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            return .cancel
        }

        func webView(
            _ webView: WKWebView,
            createWebViewWith configuration: WKWebViewConfiguration,
            for navigationAction: WKNavigationAction,
            windowFeatures: WKWindowFeatures
        ) -> WKWebView? {
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
            }
            return nil
        }
    }
}
