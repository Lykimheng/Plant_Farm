//
//  LaunchView.swift
//  PP
//
//  Created by Ly Kimheng on 7/8/26.
//
//
//import SwiftUI
//
//struct LaunchView: View {
//    /// Matches the `UIImageName` size in Info.plist's UILaunchScreen.
//    private static let logoSize: CGFloat = 200
//
//    @State private var settled = false
//    @State private var ringExpanded = false
//    @State private var showsProgress = false
//
//    var body: some View {
//        ZStack {
//            Theme.background.ignoresSafeArea()
//
//            // a single soft ring that expands out of the logo and fades — the
//            // "something is happening" cue without a busy spinner up front
//            Circle()
//                .strokeBorder(Theme.brand.opacity(ringExpanded ? 0 : 0.35), lineWidth: 2)
//                .frame(width: Self.logoSize * 0.7, height: Self.logoSize * 0.7)
//                .scaleEffect(ringExpanded ? 2.2 : 1)
//                .accessibilityHidden(true)
//
//            Image("logo")
//                .resizable()
//                .scaledToFit()
//                .frame(width: Self.logoSize, height: Self.logoSize)
//                .scaleEffect(settled ? 1 : 1.06)
//                .accessibilityLabel("Plant Farm")
//        }
//        .overlay(alignment: .bottom) {
//            ProgressView()
//                .tint(Theme.brand)
//                .opacity(showsProgress ? 1 : 0)
//                .padding(.bottom, Theme.Spacing.xxl + Theme.Spacing.lg)
//        }
//        .onAppear(perform: animate)
//    }
//
//    private func animate() {
//        // gentle breath: the logo swells slightly and settles, so the launch
//        // reads as alive rather than frozen
//        withAnimation(.spring(response: 0.55, dampingFraction: 0.6)) {
//            settled = true
//        }
//        withAnimation(.easeOut(duration: 1.1).delay(0.1)) {
//            ringExpanded = true
//        }
//        // the spinner only appears if we're still here after the intro, i.e.
//        // the network is slow — on a fast start it never shows
//        withAnimation(.easeIn(duration: 0.3).delay(1.4)) {
//            showsProgress = true
//        }
//    }
//}
//
//#Preview {
//    LaunchView()
//}
