//
//  RemoteImage.swift
//  PP
//
//  Created by Ly Kimheng on 7/8/26.
//

import SwiftUI

struct RemoteImage: View {
    let urlString: String
    var placeholderSymbol: String = Icons.leaf
    var showsPlaceholderBackground: Bool = true

    private var url: URL? {
        let trimmed = urlString.trimmed
        guard !trimmed.isEmpty else { return nil }
        return URL(string: trimmed)
    }

    var body: some View {
        if let url {
            CachedAsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable()
                case .failure:
                    placeholder
                case .empty:
                    loading
                @unknown default:
                    placeholder
                }
            }
        } else {
            placeholder
        }
    }

    private var placeholder: some View {
        ZStack {
            if showsPlaceholderBackground { Theme.surfaceAlt }
            Image(systemName: placeholderSymbol)
                .font(.system(size: 20, weight: .light))
                .foregroundStyle(Theme.textTertiary)
        }
        .accessibilityHidden(true)
    }

    private var loading: some View {
        ZStack {
            if showsPlaceholderBackground { Theme.surfaceAlt }
            ProgressView().controlSize(.small)
        }
        .accessibilityHidden(true)
    }
}

struct CachedAsyncImage<Content: View>: View {
    let url: URL
    @ViewBuilder let content: (AsyncImagePhase) -> Content

    @State private var phase: AsyncImagePhase = .empty

    var body: some View {
        content(phase)
            .task(id: url) { await load() }
    }

    private func load() async {
        if let cached = ImageMemoryCache.shared.object(forKey: url as NSURL) {
            phase = .success(Image(uiImage: cached))
            return
        }

        phase = .empty

        do {
            let (data, _) = try await URLSession.images.data(from: url)
            guard let image = UIImage(data: data) else {
                phase = .failure(URLError(.cannotDecodeContentData))
                return
            }
            ImageMemoryCache.shared.setObject(image, forKey: url as NSURL, cost: data.count)
            phase = .success(Image(uiImage: image))
        } catch is CancellationError {
        } catch {
            phase = .failure(error)
        }
    }
}

enum ImageMemoryCache {
    static let shared: NSCache<NSURL, UIImage> = {
        let cache = NSCache<NSURL, UIImage>()
        cache.totalCostLimit = 64 * 1024 * 1024
        return cache
    }()
}
