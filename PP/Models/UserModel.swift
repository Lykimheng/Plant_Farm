//
//  UserModel.swift
//  PP
//
//  Created by Ly Kimheng on 26/5/26.
//

import SwiftUI
import Combine

class UserModel: ObservableObject {
    @Published var id: Int = 0
    @Published var name: String = "Guest"
    @Published var email: String = ""
    @Published var location: String = "Unknown"
    @Published var avatarURL: String = ""
    @Published var isLoggedIn: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""

    // MARK: - Login
    func login(email: String, password: String) async {
        await MainActor.run { isLoading = true }

        let result = await APIService.shared.login(email: email, password: password)

        await MainActor.run {
            isLoading = false
            switch result {
            case .success(let response):
                if let user = response.user {
                    self.id       = user.id
                    self.name     = user.name
                    self.email    = user.email
                    self.location = user.location
                    self.avatarURL = user.avatar ?? ""
                    self.isLoggedIn = true
                    self.errorMessage = ""
                }
            case .failure(let error):
                self.errorMessage = error.message
            }
        }
    }

    // MARK: - Register
    func register(name: String, email: String, password: String, location: String) async {
        await MainActor.run { isLoading = true }

        let result = await APIService.shared.register(
            name: name, email: email,
            password: password, location: location
        )

        await MainActor.run {
            isLoading = false
            switch result {
            case .success(let response):
                if let user = response.user {
                    self.id       = user.id
                    self.name     = user.name
                    self.email    = user.email
                    self.location = user.location
                    self.avatarURL = user.avatar ?? ""
                    self.isLoggedIn = true
                    self.errorMessage = ""
                }
            case .failure(let error):
                self.errorMessage = error.message
            }
        }
    }

    // MARK: - Forgot Password
    func forgotPassword(email: String, newPassword: String) async {
        await MainActor.run { isLoading = true }

        let result = await APIService.shared.forgotPassword(
            email: email,
            newPassword: newPassword
        )

        await MainActor.run {
            isLoading = false
            switch result {
            case .success(let response):
                errorMessage = response.message
            case .failure(let error):
                errorMessage = error.message
            }
        }
    }

    // MARK: - Update Profile
    func updateProfile(name: String) async -> Bool {
        await MainActor.run { isLoading = true }

        guard let url = URL(string: "\(APIService.shared.baseURL)/update_profile.php"),
              let jsonData = try? JSONSerialization.data(withJSONObject: ["user_id": id, "name": name]) else {
            await MainActor.run { isLoading = false }
            return false
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            let success = (json?["success"] as? Bool) ?? false

            await MainActor.run {
                isLoading = false
                if success {
                    self.name = name
                } else {
                    self.errorMessage = (json?["message"] as? String) ?? "Failed to update profile."
                }
            }
            return success
        } catch {
            await MainActor.run {
                isLoading = false
                self.errorMessage = "Network error: \(error.localizedDescription)"
            }
            return false
        }
    }

    // MARK: - Upload Avatar
    func uploadAvatar(_ image: UIImage) async -> Bool {
        await MainActor.run { isLoading = true }

        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            await MainActor.run { isLoading = false }
            return false
        }
        let base64 = imageData.base64EncodedString()

        guard let url = URL(string: "\(APIService.shared.baseURL)/upload_avatar.php"),
              let jsonData = try? JSONSerialization.data(withJSONObject: ["user_id": id, "image_base64": base64]) else {
            await MainActor.run { isLoading = false }
            return false
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            let success = (json?["success"] as? Bool) ?? false

            await MainActor.run {
                isLoading = false
                if success, let avatarUrl = json?["avatar_url"] as? String {
                    self.avatarURL = avatarUrl
                } else {
                    self.errorMessage = (json?["message"] as? String) ?? "Failed to upload avatar."
                }
            }
            return success
        } catch {
            await MainActor.run {
                isLoading = false
                self.errorMessage = "Network error: \(error.localizedDescription)"
            }
            return false
        }
    }

    // MARK: - Logout
    func logout() {
        self.id         = 0
        self.name       = "Guest"
        self.email      = ""
        self.location   = "Unknown"
        self.avatarURL  = ""
        self.isLoggedIn = false
        self.errorMessage = ""
    }
}
