//
//  CameraViewModel.swift
//  PP
//
//  Created by Ly Kimheng on 3/6/26.
//

import AVFoundation
import Combine
import SwiftUI

@MainActor
final class CameraViewModel: ObservableObject {
    @Published private(set) var isRunning = false
    @Published private(set) var isFlashOn = false
    @Published private(set) var setupFailed = false
    @Published private(set) var isCapturing = false

    private let controller = CameraSessionController()

    var session: AVCaptureSession { controller.session }

    func start() {
        guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else { return }

        Task {
            let started = await controller.start()
            isRunning = started
            setupFailed = !started
        }
    }

    func stop() {
        if isFlashOn { setTorch(on: false) }
        Task {
            await controller.stop()
            isRunning = false
        }
    }

    func capturePhoto() async -> UIImage? {
        guard isRunning, !isCapturing else { return nil }
        isCapturing = true
        defer { isCapturing = false }

        do {
            return try await controller.capturePhoto()
        } catch {
            AppLog.warning("Photo capture failed: \(error.localizedDescription)")
            return nil
        }
    }

    func toggleFlash() {
        setTorch(on: !isFlashOn)
    }

    private func setTorch(on: Bool) {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              device.hasTorch else { return }

        do {
            try device.lockForConfiguration()
            device.torchMode = on ? .on : .off
            device.unlockForConfiguration()
            isFlashOn = on
        } catch {
            AppLog.warning("Torch unavailable: \(error.localizedDescription)")
        }
    }
}

nonisolated enum CameraError: LocalizedError {
    case notRunning
    case emptyCapture

    var errorDescription: String? {
        switch self {
        case .notRunning:   return "The camera isn't running."
        case .emptyCapture: return "The camera didn't return a photo."
        }
    }
}

private actor CameraSessionController {
    nonisolated let session = AVCaptureSession()

    private let photoOutput = AVCapturePhotoOutput()
    private var rotationCoordinator: AVCaptureDevice.RotationCoordinator?
    private var isConfigured = false

    func start() async -> Bool {
        if !isConfigured {
            guard configure() else { return false }
            isConfigured = true
        }

        guard !session.isRunning else { return true }
        session.startRunning()
        return true
    }

    func stop() async {
        guard session.isRunning else { return }
        session.stopRunning()
    }

    func capturePhoto() async throws -> UIImage {
        guard session.isRunning, session.outputs.contains(photoOutput) else {
            throw CameraError.notRunning
        }

        if let connection = photoOutput.connection(with: .video),
           let angle = rotationCoordinator?.videoRotationAngleForHorizonLevelCapture,
           connection.isVideoRotationAngleSupported(angle) {
            connection.videoRotationAngle = angle
        }

        let settings = AVCapturePhotoSettings()
        settings.flashMode = .off

        return try await withCheckedThrowingContinuation { continuation in
            let delegate = PhotoCaptureDelegate(continuation: continuation)
            photoOutput.capturePhoto(with: settings, delegate: delegate)
        }
    }

    private func configure() -> Bool {
        session.beginConfiguration()
        defer { session.commitConfiguration() }

        session.sessionPreset = .photo

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            return false
        }
        session.addInput(input)

        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }
        rotationCoordinator = AVCaptureDevice.RotationCoordinator(device: device, previewLayer: nil)
        return true
    }
}

private nonisolated final class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    private var continuation: CheckedContinuation<UIImage, Error>?
    private var keepAlive: PhotoCaptureDelegate?

    init(continuation: CheckedContinuation<UIImage, Error>) {
        self.continuation = continuation
        super.init()
        keepAlive = self
    }

    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        guard let continuation else { return }
        self.continuation = nil

        if let error {
            continuation.resume(throwing: error)
        } else if let data = photo.fileDataRepresentation(), let image = UIImage(data: data) {
            continuation.resume(returning: image)
        } else {
            continuation.resume(throwing: CameraError.emptyCapture)
        }
    }

    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings,
                     error: Error?) {
        // Called last, even on failure; the continuation was already resumed above,
        // except when processing never ran at all.
        if let continuation {
            self.continuation = nil
            continuation.resume(throwing: error ?? CameraError.emptyCapture)
        }
        keepAlive = nil
    }
}
