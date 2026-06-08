//
//  ImageSliderView.swift
//  PP
//
//  Created by Ly Kimheng on 25/12/25.
//
import SwiftUI
import Combine

struct ImageSliderView: View {
    let images = ["photo1", "photo2", "photo3", "photo4"]

    @State private var currentIndex = 0
    @State private var progress: CGFloat = 0

    let slideDuration: CGFloat = 3
    let timer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack(alignment: .bottom) {

            // MARK: Image Slider
            GeometryReader { geo in
                HStack(spacing: 0) {
                    ForEach(images, id: \.self) { image in
                        Image(image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width, height: geo.size.height)
                            .clipped()
                    }
                }
                .offset(x: -CGFloat(currentIndex) * geo.size.width)
                .animation(.easeInOut, value: currentIndex)
            }
            .frame(height: 240)
            .clipped()

            // MARK: Apple-style Indicator
            HStack(spacing: 8) {
                ForEach(images.indices, id: \.self) { index in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.4))
                            .frame(width: index == currentIndex ? 28 : 8, height: 8)

                        if index == currentIndex {
                            Capsule()
                                .fill(Color.white)
                                .frame(width: 28 * progress, height: 8)
                        }
                    }
                }
            }
            .padding(.bottom, 12)
        }
        .onReceive(timer) { _ in
            progress += 0.02 / slideDuration

            if progress >= 1 {
                progress = 0
                currentIndex = (currentIndex + 1) % images.count
            }
        }
    }
}

#Preview {
    ImageSliderView()
}
