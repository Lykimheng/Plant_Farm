//
//  KHQRCard.swift
//  PP
//
//  Created by Ly Kimheng on 3/11/26.
//

import SwiftUI

// stays white in dark mode: bank apps read a dark code on a light card best
struct KHQRCard: View {
    let amount: Double
    private let code: UIImage?

    private static let khqrRed = Color(hex: 0xE1232E)

    init(qrString: String, amount: Double) {
        self.amount = amount
        self.code = QRCodeImage.make(from: qrString)
    }

    var body: some View {
        VStack(spacing: 0) {
            Text(verbatim: "KHQR")
                .font(.system(size: 22, weight: .heavy))
                .tracking(1.5)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Self.khqrRed)

            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: "Plant Farm")
                    .font(.system(size: 13, weight: .semibold))
                    .opacity(0.7)
                Text(amount.priceText)
                    .font(.system(size: 26, weight: .bold))
            }
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 22)
            .padding(.vertical, 14)

            DashedLine()
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [5, 4]))
                .foregroundStyle(Color.black.opacity(0.25))
                .frame(height: 1)

            Group {
                if let code {
                    Image(uiImage: code)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                } else {
                    Image(systemName: "qrcode")
                        .font(.system(size: 60))
                        .foregroundStyle(Color.black.opacity(0.3))
                }
            }
            .frame(width: 228, height: 228)
            .padding(22)
        }
        .frame(width: 272)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("KHQR code for \(amount.priceText)"))
    }

    // the image saved to Photos, with a margin so a bank app finds the code
    func snapshot() -> UIImage? {
        let renderer = ImageRenderer(content: padding(20).background(Color.white))
        renderer.scale = 3
        return renderer.uiImage
    }
}

private struct DashedLine: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        }
    }
}

#Preview {
    KHQRCard(qrString: "00020101021230510016abaakhppxxx@abaa", amount: 37.5)
        .padding()
        .background(Theme.background)
}
