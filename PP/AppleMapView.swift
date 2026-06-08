//
//  AppleMapView.swift
//  PP
//
//  Created by Ly Kimheng on 5/6/26.
//
import SwiftUI
import MapKit
import CoreLocation

struct AppleMapView: UIViewRepresentable {
    var coordinate: CLLocationCoordinate2D

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.showsUserLocation = true

        // set region around coordinate
        let region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        mapView.setRegion(region, animated: false)

        // add marker
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Delivery Location"
        mapView.addAnnotation(annotation)

        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        let region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        mapView.setRegion(region, animated: true)
    }
}

#Preview {
    AppleMapView(coordinate: CLLocationCoordinate2D(
        latitude: 11.5564,
        longitude: 104.9282
    ))
    .frame(height: 300)
    .cornerRadius(12)
}
