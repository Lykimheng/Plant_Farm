//
//  KHQRCard.swift
//  PP
//
//  Created by Ly Kimheng on 3/11/26.
//

import SwiftUI

// laid out as in ABA's merchant guidelines; stays white in dark mode,
// since bank apps read a dark code on a light card best
struct KHQRCard: View {
    let amount: Double
    private let code: UIImage?

    private static let khqrRed = Color(hex: 0xE1232E)
    private static let bandHeight: CGFloat = 50
    private static let foldSize: CGFloat = 18

    init(qrString: String, amount: Double) {
        self.amount = amount
        self.code = QRCodeImage.make(from: qrString)
    }

    var body: some View {
        VStack(spacing: 0) {
            Image("PayKHQRWordmark")
                .resizable()
                .scaledToFit()
                .frame(height: 24)
                .frame(height: Self.bandHeight)

            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: "Plant Farm")
                    .font(.system(size: 13, weight: .medium))
                    .opacity(0.75)
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(verbatim: String(format: "%.2f", amount))
                        .font(.system(size: 26, weight: .bold))
                    Text(verbatim: "USD")
                        .font(.system(size: 13))
                        .opacity(0.75)
                }
            }
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 28)
            .padding(.vertical, 12)

            DashedLine()
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [6, 5]))
                .foregroundStyle(Color.black.opacity(0.35))
                .frame(height: 1)

            ZStack {
                if let code {
                    Image(uiImage: code)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                    currencyMark
                } else {
                    Image(systemName: "qrcode")
                        .font(.system(size: 60))
                        .foregroundStyle(Color.black.opacity(0.3))
                }
            }
            .frame(width: 216, height: 216)
            .padding(.vertical, 24)
        }
        .frame(width: 272)
        .background(alignment: .top) {
            FoldedBand(foldSize: Self.foldSize)
                .fill(Self.khqrRed)
                .frame(height: Self.bandHeight + Self.foldSize)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("KHQR code for \(amount.priceText)"))
    }

    private var currencyMark: some View {
        Circle()
            .fill(.black)
            .frame(width: 34, height: 34)
            .overlay {
                Text(verbatim: "$")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(.white)
            }
            .padding(3)
            .background(.white, in: Circle())
    }

    // the image saved to Photos, with a margin so a bank app finds the code
    func snapshot() -> UIImage? {
        let renderer = ImageRenderer(content: padding(20).background(Color.white))
        renderer.scale = 3
        return renderer.uiImage
    }
}

private struct FoldedBand: Shape {
    let foldSize: CGFloat

    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX - foldSize, y: rect.maxY - foldSize))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - foldSize))
            path.closeSubpath()
        }
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
