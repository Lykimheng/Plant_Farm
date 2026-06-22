//
//  RemoteImage.swift
//  PP
//
//  Created by Ly Kimheng on 20/6/26.
//

import SwiftUI

// MARK: - Loads a plant image from a URL string
struct RemoteImage: View {
    let urlString: String
    @State private var retryCount = 0

    var body: some View {
        AsyncImage(url: URL(string: urlString)) { phase in
            if let image = phase.image {
                image.resizable()
            } else if let error = phase.error {
                Image(systemName: "photo")
                    .resizable()
                    .foregroundColor(.gray.opacity(0.4))
                    .task {
                        let isCancelled = (error as NSError).code == NSURLErrorCancelled
                        if isCancelled && retryCount < 2 {
                            try? await Task.sleep(nanoseconds: 300_000_000)
                            retryCount += 1
                        }
                    }
            } else {
                ProgressView()
            }
        }
        .id(retryCount)
    }
}
