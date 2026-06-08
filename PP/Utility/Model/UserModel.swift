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
                    self.isLoggedIn = true
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
                    self.isLoggedIn = true
                }
            case .failure(let error):
                self.errorMessage = error.message
            }
        }
    }

    // MARK: - Logout
    func logout() {
        self.id         = 0
        self.name       = "Guest"
        self.email      = ""
        self.location   = "Unknown"
        self.isLoggedIn = false
    }
}
