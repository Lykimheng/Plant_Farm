//
//  ToastCenter.swift
//  PP
//
//  Created by Ly Kimheng on 20/6/26.
//

import SwiftUI
import Combine

// MARK: - Notifaction_Popup
class ToastCenter: ObservableObject {
    @Published var message: String = ""
    @Published var isShowing: Bool = false

    func show(_ message: String) {
        self.message = message
        self.isShowing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isShowing = false
        }
    }
}
