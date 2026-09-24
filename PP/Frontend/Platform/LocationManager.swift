//
//  LocationManager.swift
//  PP
//
//  Created by Ly Kimheng on 12/8/26.
//

import CoreLocation
import MapKit
import SwiftUI
import Combine

@MainActor
final class LocationManager: NSObject, ObservableObject {
    @Published private(set) var userLocation: CLLocationCoordinate2D?
    @Published private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published private(set) var userAddress: String = ""

    private let manager = CLLocationManager()
    private var hasRequestedPermission = false

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        authorizationStatus = manager.authorizationStatus
    }

    var isDenied: Bool {
        authorizationStatus == .denied || authorizationStatus == .restricted
    }

    var isAuthorized: Bool {
        authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    }

    func requestPermissionIfNeeded() {
        guard !hasRequestedPermission else {
            if isAuthorized && userLocation == nil { manager.requestLocation() }
            return
        }
        hasRequestedPermission = true

        switch authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        default:
            break
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            self.authorizationStatus = status
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                // one-shot: the delivery address doesn't need continuous tracking
                manager.requestLocation()
            case .denied, .restricted:
                self.userAddress = ""
            default:
                break
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            self.userLocation = location.coordinate
            await self.resolveAddress(for: location)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            AppLog.warning("Location lookup failed: \(error.localizedDescription)")
        }
    }

    private func resolveAddress(for location: CLLocation) async {
        guard let request = MKReverseGeocodingRequest(location: location),
              let mapItem = try? await request.mapItems.first else { return }

        let address = mapItem.address
        let parts = [address?.shortAddress, address?.fullAddress]
            .compactMap { $0 }
            .filter { !$0.isEmpty }

        userAddress = parts.first ?? mapItem.name ?? ""
    }
}
