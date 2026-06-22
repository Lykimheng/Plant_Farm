//
//  CameraViewModel.swift
//  PP
//
//  Created by Ly Kimheng on 3/6/26.
//

import SwiftUI
import AVFoundation
import Combine

class CameraViewModel: ObservableObject {
    @Published var session = AVCaptureSession()
    @Published var isFlashOn = false
    @Published var capturedImage: UIImage? = nil

    func setupCamera() {
        // check permission first
        guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else {
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            self.session.beginConfiguration()

            guard let device = AVCaptureDevice.default(
                .builtInWideAngleCamera, for: .video, position: .back),
                let input = try? AVCaptureDeviceInput(device: device)
            else {
                print("Camera device not available")
                return
            }

            if self.session.canAddInput(input) {
                self.session.addInput(input)
            }

            let output = AVCapturePhotoOutput()
            if self.session.canAddOutput(output) {
                self.session.addOutput(output)
            }

            self.session.commitConfiguration()
            self.session.startRunning()        //start after commitConfiguration
        }
    }

    func stopCamera() {
        session.stopRunning()
    }

    func toggleFlash() {
        guard let device = AVCaptureDevice.default(for: .video),
              device.hasTorch else { return }
        try? device.lockForConfiguration()
        isFlashOn.toggle()
        device.torchMode = isFlashOn ? .on : .off
        device.unlockForConfiguration()
    }
}
