//
//  CameraMenager.swift
//  PP
//
//  Created by Ly Kimheng on 3/6/26.
//

import SwiftUI
import AVFoundation
import PhotosUI
import Combine

class CameraPermissionManager: ObservableObject {
    @Published var cameraPermission: AVAuthorizationStatus = .notDetermined
    @Published var photoPermission: PHAuthorizationStatus = .notDetermined
    @Published var showPermissionAlert = false

    // check current status on init
    init() {
        cameraPermission = AVCaptureDevice.authorizationStatus(for: .video)
        photoPermission = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }

    // MARK: - Camera
    func requestCameraPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            cameraPermission = .authorized
            completion(true)

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    self.cameraPermission = granted ? .authorized : .denied
                    if !granted { self.showPermissionAlert = true }
                    completion(granted)
                }
            }

        case .denied, .restricted:
            cameraPermission = .denied
            showPermissionAlert = true
            completion(false)

        @unknown default:
            completion(false)
        }
    }

    // MARK: - Photo Library
    func requestPhotoPermission(completion: @escaping (Bool) -> Void) {
        switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
        case .authorized, .limited:
            photoPermission = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            completion(true)

        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                DispatchQueue.main.async {
                    self.photoPermission = status
                    let granted = status == .authorized || status == .limited
                    if !granted { self.showPermissionAlert = true }
                    completion(granted)
                }
            }

        case .denied, .restricted:
            photoPermission = .denied
            showPermissionAlert = true
            completion(false)

        @unknown default:
            completion(false)
        }
    }

    var isCameraAuthorized: Bool {
        cameraPermission == .authorized
    }

    var isPhotoAuthorized: Bool {
        photoPermission == .authorized || photoPermission == .limited
    }
}
