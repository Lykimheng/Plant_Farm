//
//  InlineError.swift
//  PP
//
//  Created by Ly Kimheng on 24/9/26.
//

import SwiftUI

struct InlineError: View {
    let message: LocalizedStringResource?

    var body: some View {
        if let message {
            Label {
                Text(message)
            } icon: {
                Image(systemName: "exclamationmark.triangle")
            }
            .font(.system(size: 12.5))
            .foregroundStyle(Theme.danger)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityAddTraits(.isStaticText)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        InlineError(message: "Enter a valid email address.")
        InlineError(message: nil)
    }
    .padding()
}
