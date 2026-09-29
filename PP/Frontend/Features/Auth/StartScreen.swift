//
//  StartScreen.swift
//  PP
//  Created by Ly Kimheng on 25/12/25.
//

import SwiftUI

struct StartScreen: View {
    var onContinueAsGuest: () -> Void

    @State private var showSignIn = false
    @State private var showSignUp = false
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    private var isWide: Bool { sizeClass == .regular }
    /// A phone on its side: the headline and buttons need to share ~350pt of height.
    private var isShort: Bool { verticalSizeClass == .compact }
    private var alignment: HorizontalAlignment { isWide ? .center : .leading }
    private var textAlignment: TextAlignment { isWide ? .center : .leading }

    var body: some View {
        content
            .frame(maxWidth: .infinity)
            // sits at the bottom as designed, but scrolls rather than clipping
            // the headline if a short screen can't fit it all
            .scrollableWhenNeeded(alignment: .bottom)
            .background { backdrop }
            .sheet(isPresented: $showSignIn) {
                SignInView(onSwitchToSignUp: {
                    showSignIn = false
                    // let the first sheet finish dismissing before presenting the next
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { showSignUp = true }
                })
                .presentationDetents([.height(520), .large])
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showSignUp) {
                SignUpView(onSwitchToSignIn: {
                    showSignUp = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { showSignIn = true }
                })
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
    }

    private var backdrop: some View {
        ZStack {
            Image("Background")
                .resizable()
                .scaledToFill()
                .accessibilityHidden(true)
            LinearGradient(
                colors: [.black.opacity(0.05), .black.opacity(0.65)],
                startPoint: .center,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea()
    }

    private var content: some View {
        VStack(alignment: alignment, spacing: Theme.Spacing.xl) {
            VStack(alignment: alignment, spacing: Theme.Spacing.sm) {
                Text("The best app\nfor your plants")
                    .font(.system(size: isShort ? 30 : 40, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(textAlignment)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Shop, track and care for every plant in your home.")
                    .font(.system(size: 15))
                    .foregroundStyle(.white.opacity(0.85))
                    .multilineTextAlignment(textAlignment)
            }

            VStack(spacing: Theme.Spacing.md) {
                Button("Sign in") { showSignIn = true }
                    .buttonStyle(.primary)

                Button("Create an account") { showSignUp = true }
                    .buttonStyle(SecondaryButtonStyle(tint: .white))

                Button("Continue as guest", action: onContinueAsGuest)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.85))
                    .padding(.top, Theme.Spacing.xs)
            }
        }
        .frame(maxWidth: .infinity, alignment: Alignment(horizontal: alignment, vertical: .center))
        .padding(.horizontal, Theme.Spacing.xl)
        .padding(.top, Theme.Spacing.lg)
        .padding(.bottom, isShort ? Theme.Spacing.lg : Theme.Spacing.xxl + Theme.Spacing.lg)
        // a phone-sized column on wide screens — centred rather than stretched
        .frame(maxWidth: Theme.Layout.compact)
        .frame(maxWidth: .infinity, alignment: Alignment(horizontal: alignment, vertical: .center))
    }
}

#Preview {
    StartScreen(onContinueAsGuest: {})
        .environmentObject(UserStore())
}
