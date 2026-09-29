//
//  CameraPreview.swift
//  PP
//
//  Created by Ly Kimheng on 3/6/26.
//

import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    /// The preview's connection only exists once the session is running, so the
    /// rotation is re-applied when this flips.
    var isRunning: Bool = false

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.backgroundColor = .black
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {
        uiView.updateRotation()
    }

    class PreviewView: UIView {
        override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }

        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            return layer as! AVCaptureVideoPreviewLayer
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            videoPreviewLayer.frame = bounds    // auto resize with view
            updateRotation()                    // bounds change when the interface rotates
        }

        /// Keeps the feed upright in landscape (iPhone on its side, iPad); the layer
        /// otherwise always draws it portrait.
        func updateRotation() {
            guard let connection = videoPreviewLayer.connection,
                  let orientation = window?.windowScene?.effectiveGeometry.interfaceOrientation
            else { return }

            let angle: CGFloat = switch orientation {
            case .landscapeRight:     0
            case .landscapeLeft:      180
            case .portraitUpsideDown: 270
            default:                  90
            }

            if connection.videoRotationAngle != angle, connection.isVideoRotationAngleSupported(angle) {
                connection.videoRotationAngle = angle
            }
        }
    }
}
