//
//  UserStore.swift
//  PP
//
//  Created by Ly Kimheng on 12/8/26.
//

import SwiftUI
import Combine

@MainActor
final class UserStore: ObservableObject {
    @Published private(set) var id: Int = 0
    @Published private(set) var name: String = "Guest"
    @Published private(set) var email: String = ""
    @Published private(set) var location: String = "Unknown"
    @Published private(set) var avatarURL: String = ""
    @Published private(set) var isLoggedIn: Bool = false
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String = ""

    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    // MARK: - Auth

    @discardableResult
    func login(email: String, password: String) async -> Bool {
        await authenticate {
            try await self.client.send(
                API.Path.login,
                method: .post,
                body: LoginRequest(email: email.trimmed, password: password)
            )
        }
    }

    @discardableResult
    func register(name: String, email: String, password: String, location: String) async -> Bool {
        await authenticate {
            try await self.client.send(
                API.Path.register,
                method: .post,
                body: RegisterRequest(
                    name: name.trimmed,
                    email: email.trimmed,
                    password: password,
                    location: location
                )
            )
        }
    }
    
    func resetPassword(email: String, newPassword: String) async -> Bool {
        isLoading = true
        errorMessage = ""
        defer { isLoading = false }

        do {
            let _: StatusResponse = try await client.send(
                API.Path.forgotPassword,
                method: .post,
                body: ForgotPasswordRequest(email: email.trimmed, newPassword: newPassword)
            )
            return true
        } catch {
            errorMessage = error.userMessage
            return false
        }
    }

    func logout() {
        id = 0
        name = "Guest"
        email = ""
        location = "Unknown"
        avatarURL = ""
        isLoggedIn = false
        errorMessage = ""
    }

    // MARK: - Profile

    func updateProfile(name newName: String) async -> Bool {
        let trimmed = newName.trimmed
        guard !trimmed.isEmpty else {
            errorMessage = "Name can't be empty."
            return false
        }

        isLoading = true
        errorMessage = ""
        defer { isLoading = false }

        do {
            let _: StatusResponse = try await client.send(
                API.Path.updateProfile,
                method: .put,
                body: UpdateProfileRequest(userId: id, name: trimmed)
            )
            name = trimmed
            return true
        } catch {
            errorMessage = error.userMessage
            return false
        }
    }

    func uploadAvatar(_ image: UIImage) async -> Bool {
        guard let data = image.resized(maxDimension: 800).jpegData(compressionQuality: 0.7) else {
            errorMessage = "That image couldn't be prepared for upload."
            return false
        }

        isLoading = true
        errorMessage = ""
        defer { isLoading = false }

        do {
            let response: AvatarResponse = try await client.send(
                API.Path.uploadAvatar,
                method: .post,
                body: UploadAvatarRequest(userId: id, imageBase64: data.base64EncodedString())
            )
            if let url = response.avatarURL { avatarURL = url }
            return true
        } catch {
            errorMessage = error.userMessage
            return false
        }
    }

    // MARK: - Helpers

    private func authenticate(_ request: () async throws -> UserResponse) async -> Bool {
        isLoading = true
        errorMessage = ""
        defer { isLoading = false }

        do {
            let response = try await request()
            guard let user = response.user else {
                errorMessage = response.message ?? "Something went wrong. Please try again."
                return false
            }
            apply(user)
            return true
        } catch {
            errorMessage = error.userMessage
            return false
        }
    }

    private func apply(_ user: UserDTO) {
        id = user.id
        name = user.name
        email = user.email
        location = user.location
        avatarURL = user.avatar ?? ""
        isLoggedIn = true
        errorMessage = ""
    }
}
