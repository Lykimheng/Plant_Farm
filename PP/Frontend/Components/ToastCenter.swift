//
//  ToastCenter.swift
//  PP
//
//  Created by Ly Kimheng on 29/5/26.
//

import SwiftUI
import Combine

@MainActor
final class ToastCenter: ObservableObject {
    @Published private(set) var message: LocalizedStringResource?
    @Published var isShowing: Bool = false

    private var dismissTask: Task<Void, Never>?

    func show(_ message: LocalizedStringResource, duration: TimeInterval = 2) {
        self.message = message

        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            isShowing = true
        }
        dismissTask?.cancel()
        dismissTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(duration))
            guard !Task.isCancelled else { return }
            self?.dismiss()
        }
    }

    func dismiss() {
        withAnimation(.easeOut(duration: 0.25)) {
            isShowing = false
        }
    }
}
