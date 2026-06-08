//
//  ViewExtensions.swift
//  PP
//
//  Created by Ly Kimheng on 23/1/26.
//
import SwiftUI

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
    
    func toast(isShowing: Binding<Bool>, message: String) -> some View {
        ZStack(alignment: .top) {
            self
            if isShowing.wrappedValue {
                ToastView(message: message)
                    .padding(.top, 16)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.spring(), value: isShowing.wrappedValue)
                    .zIndex(1)
            }
        }
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
