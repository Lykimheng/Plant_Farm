//
//  CameraPermissionManager.swift
//  PP
//
//  Created by Ly Kimheng on 3/6/26.
//

import AVFoundation
import PhotosUI
import SwiftUI
import Combine

@MainActor
final class CameraPermissionManager: ObservableObject {
    @Published private(set) var cameraStatus: AVAuthorizationStatus
    @Published private(set) var photoStatus: PHAuthorizationStatus

    init() {
        cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
        photoStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }

    var isCameraAuthorized: Bool { cameraStatus == .authorized }
    var isCameraDenied: Bool { cameraStatus == .denied || cameraStatus == .restricted }
    var isPhotoAuthorized: Bool { photoStatus == .authorized || photoStatus == .limited }

    @discardableResult
    func requestCamera() async -> Bool {
        switch cameraStatus {
        case .authorized:
            return true
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            cameraStatus = granted ? .authorized : .denied
            return granted
        default:
            return false
        }
    }

    @discardableResult
    func requestPhotoLibrary() async -> Bool {
        switch photoStatus {
        case .authorized, .limited:
            return true
        case .notDetermined:
            let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
            photoStatus = status
            return status == .authorized || status == .limited
        default:
            return false
        }
    }

    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
