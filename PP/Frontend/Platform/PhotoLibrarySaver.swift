//
//  PhotoLibrarySaver.swift
//  PP
//
//  Created by Ly Kimheng on 3/11/26.
//

import Photos
import UIKit

nonisolated enum PhotoLibrarySaver {
    enum Failure: Error {
        case accessDenied
        case unreadableImage
    }

    static func save(_ image: UIImage) async throws {
        guard let data = image.pngData() else { throw Failure.unreadableImage }

        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        guard status == .authorized || status == .limited else { throw Failure.accessDenied }

        try await PHPhotoLibrary.shared().performChanges {
            PHAssetCreationRequest.forAsset().addResource(with: .photo, data: data, options: nil)
        }
    }
}
