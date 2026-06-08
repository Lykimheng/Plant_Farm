//
//  ScanView.swift
//  PP
//
//  Created by Ly Kimheng on 26/12/25.
//
import SwiftUI
import AVFoundation
import PhotosUI

struct ScanView: View {
    @StateObject private var camera = CameraViewModel()
    @StateObject private var permission = CameraPermissionManager()
    @State private var selectedImage: UIImage? = nil
    @State private var showPhotoLibrary = false
    @State private var isScanning = false           // ← scanning animation
    @State private var scanOffset: CGFloat = -150   // ← animation position
    let scanSize: CGFloat = 280
    var body: some View {
        ZStack {
            // MARK: - Camera Background
            CameraPreview(session: camera.session)
                .ignoresSafeArea()
            
            // MARK: - Dark overlay outside scan area
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .mask(
                    ZStack {
                        Rectangle()
                        RoundedRectangle(cornerRadius: 16)
                            .frame(width: 280, height: 280)
                            .blendMode(.destinationOut)
                    }
                        .compositingGroup()
                )
            
            // MARK: - Scan frame corners
            RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.clear, lineWidth: 0)
                    .frame(width: scanSize, height: scanSize)
                    .overlay(
                        ZStack {
                            // top left
                            ScanCorner()
                                .frame(width: 24, height: 24)
                                .offset(x: -2, y: -2)           // ← slight outside offset
                                .frame(maxWidth: .infinity, maxHeight: .infinity,
                                       alignment: .topLeading)

                            // top right
                            ScanCorner()
                                .rotationEffect(.degrees(90))
                                .frame(width: 24, height: 24)
                                .offset(x: 2, y: -2)
                                .frame(maxWidth: .infinity, maxHeight: .infinity,
                                       alignment: .topTrailing)

                            // bottom left
                            ScanCorner()
                                .rotationEffect(.degrees(270))
                                .frame(width: 24, height: 24)
                                .offset(x: -2, y: 2)
                                .frame(maxWidth: .infinity, maxHeight: .infinity,
                                       alignment: .bottomLeading)

                            // bottom right
                            ScanCorner()
                                .rotationEffect(.degrees(180))
                                .frame(width: 24, height: 24)
                                .offset(x: 2, y: 2)
                                .frame(maxWidth: .infinity, maxHeight: .infinity,
                                       alignment: .bottomTrailing)
                        }
                    )
            
            // MARK: - Scanning line animation
            if isScanning {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.clear,
                                     Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255).opacity(0.8),
                                     .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 260, height: 3)
                    .offset(y: scanOffset)
                    .animation(
                        .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                        value: scanOffset
                    )
            }
            
            // MARK: - Bottom controls
            VStack {
                Spacer()
                HStack {
                    // Flash button
                    Button {
                        camera.toggleFlash()
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: camera.isFlashOn ? "bolt.fill" : "bolt.slash")
                                .font(.title2)
                                .foregroundColor(.white)
                            Text("Flash")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                    }
                    
                    Spacer()
                    
                    // Image library button
                    Button {
                        permission.requestPhotoPermission { granted in
                            if granted {
                                showPhotoLibrary = true
                            }
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.title2)
                                .foregroundColor(.white)
                            Text("Image")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal, 60)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            permission.requestCameraPermission { granted in
                if granted {
                    camera.setupCamera()
                    startScanning()
                }
            }
        }
        .onDisappear {
            camera.stopCamera()
        }
        .sheet(isPresented: $showPhotoLibrary) {
            ImagePicker(selectedImage: $selectedImage, sourceType: .photoLibrary)
        }
        .preferredColorScheme(.light)
    }
    
    // MARK: - Start scanning animation
    func startScanning() {
        isScanning = true
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            scanOffset = 150
        }
    }
}
// MARK: - Corner shape
struct ScanCorner: View {
    var size: CGFloat = 24
    var thickness: CGFloat = 4
    var color: Color = Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255)

    var body: some View {
        ZStack(alignment: .topLeading) {
            Path { path in
                path.move(to: CGPoint(x: 0, y: size))
                path.addLine(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: size, y: 0))
            }
            .stroke(color, style: StrokeStyle(
                lineWidth: thickness,
                lineCap: .round,
                lineJoin: .round
            ))
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    ScanView()
}
