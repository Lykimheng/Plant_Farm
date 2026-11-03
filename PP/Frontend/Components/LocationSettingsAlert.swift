//
//  LocationSettingsAlert.swift
//  PP
//
//  Created by Ly Kimheng on 3/11/26.
//

import SwiftUI

extension View {
    func locationSettingsAlert(isPresented: Binding<Bool>, turningOff: Bool = false) -> some View {
        modifier(LocationSettingsAlert(isPresented: isPresented, turningOff: turningOff))
    }
}

private struct LocationSettingsAlert: ViewModifier {
    @EnvironmentObject private var location: LocationManager
    @Binding var isPresented: Bool
    let turningOff: Bool

    func body(content: Content) -> some View {
        content.alert(turningOff ? "Turn off location?" : "Turn on location", isPresented: $isPresented) {
            Button("Open Settings") { location.openSettings() }
            Button("Not now", role: .cancel) {}
        } message: {
            if turningOff {
                Text("iOS manages location access. In Settings, tap Location and choose Never.")
            } else {
                Text("Location access is off for Plant Farm. In Settings, tap Location and choose While Using the App so we can fill in your delivery address.")
            }
        }
    }
}
