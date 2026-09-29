//
//  Endpoint.swift
//  PP
//
//  Created by Ly Kimheng on 10/9/26.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

nonisolated enum API {
    static let baseURL: URL = {
        let override = UserDefaults.standard.string(forKey: "APIBaseURL")
            ?? ProcessInfo.processInfo.environment["API_BASE_URL"]

        if let override, let url = URL(string: override) {
            return url
        }
        return URL(string: "http://172.20.10.13:8001")! //MARK: Machin IP here
    }()

    static var apiURL: URL { baseURL.appendingPathComponent("api") }

    // MARK: - Paths

    enum Path {
        static let register = "register"
        static let login = "login"
        static let forgotPassword = "forgot_password"
        static let updateProfile = "update_profile"
        static let uploadAvatar = "upload_avatar"
        static let plants = "plants"
        static let reviews = "reviews"
        static let myPlants = "my_plants"
        static let orders = "orders"
        static let notifications = "notifications"
    }

    // MARK: - Static assets served by the backend

    static func categoryIconURL(_ name: String) -> String {
        assetURL("categories", name)
    }

    static func bannerURL(_ name: String) -> String {
        assetURL("banners", name)
    }

    private static func assetURL(_ folder: String, _ name: String) -> String {
        baseURL
            .appendingPathComponent("uploads")
            .appendingPathComponent(folder)
            .appendingPathComponent("\(name).png")
            .absoluteString
    }
}
