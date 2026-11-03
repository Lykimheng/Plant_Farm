//
//  PhotoSettingsAlert.swift
//  PP
//
//  Created by Ly Kimheng on 3/11/26.
//

import SwiftUI

extension View {
    func photoSettingsAlert(isPresented: Binding<Bool>, permission: CameraPermissionManager) -> some View {
        alert("Turn on photo access", isPresented: isPresented) {
            Button("Open Settings") { permission.openSettings() }
            Button("Not now", role: .cancel) {}
        } message: {
            Text("Photo access is off for Plant Farm. In Settings, tap Photos and choose Full Access or Limited Access so you can pick a photo.")
        }
    }
}
