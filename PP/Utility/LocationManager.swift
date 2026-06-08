//
//  LocationManager.swift
//  PP
//
//  Created by Ly Kimheng on 5/6/26.
//

import SwiftUI
import CoreLocation
import Combine
import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    @Published var userLocation: CLLocationCoordinate2D? = nil
    @Published var locationStatus: CLAuthorizationStatus = .notDetermined
    @Published var userAddress: String = ""
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // ← request permission
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }
    
    // ← start getting location
    func startUpdating() {
        manager.startUpdatingLocation()
    }
    
    func stopUpdating() {
        manager.stopUpdatingLocation()
    }
    
    // ← called when permission changes
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationStatus = manager.authorizationStatus
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            startUpdating()                    // ← start once allowed
        case .denied, .restricted:
            userAddress = "Location access denied"
        default:
            break
        }
    }
    
    // ← called when location updates
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.userLocation = location.coordinate
        }
        reverseGeocode(location: location)
        manager.stopUpdatingLocation()         // ← stop after getting location
    }
    
    // ← called on error
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
    
    // ← convert coordinates to readable address
    func reverseGeocode(location: CLLocation) {
        Task {
            await withCheckedContinuation { continuation in
                let geocoder = CLGeocoder()
                geocoder.reverseGeocodeLocation(location) { placemarks, error in
                    if let placemark = placemarks?.first {
                        DispatchQueue.main.async {
                            self.userAddress = [
                                placemark.subLocality,
                                placemark.locality,
                                placemark.country
                            ]
                                .compactMap { $0 }
                                .joined(separator: ", ")
                        }
                    }
                    continuation.resume()
                }
            }
        }
    }
}
