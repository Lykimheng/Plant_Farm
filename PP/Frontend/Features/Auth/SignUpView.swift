//
//  SignupView.swift
//  PP
//
//  Created by Ly Kimheng on 25/12/25.
//

import SwiftUI
import Combine

struct SignupView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var user: UserModel
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    var body: some View {
            VStack(spacing: 20) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: Constants.backIcon)
                                .foregroundStyle(Color.blue)
                            Text("Back")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.blue)
                        }
                    }

                    Spacer()
                }
                .overlay(
                    Text("Sign up")
                        .foregroundStyle(Color(.sRGB, red: 32/255, green: 169/255, blue: 172/255))
                        .font(.largeTitle.bold())
                )

                .padding(20)
                VStack(spacing: 20){
                    InputField(icon: Constants.userIcon, placeholder: "User name", text: $username)
                    InputField(icon: Constants.mailIcon, placeholder: "Email", text: $email)
                    InputPasswardField(password: $password)
                    InputPasswardConField(password: $confirmPassword)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                Spacer()
                if !user.errorMessage.isEmpty {
                    Text(user.errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal, 20)
                }
                
                // SIGN IN BUTTON (BOTTOM SHEET)
                Button {
                    guard password == confirmPassword else {
                        user.errorMessage = "Password doesn't match"
                        return
                    }
                    Task{
                        await user.register(name: username, email: email, password: password, location: "Phnom Penh")
                        if user.isLoggedIn {
                            dismiss()
                        }
                    }
                } label: {
                    if user.isLoading {
                        ProgressView()
                            .frame(width: 200, height: 50)
                    } else {
                        Text("Sign up")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(Color(.sRGB, red: 32/255, green: 169/255, blue: 172/255, opacity: 1.0))
                            .cornerRadius(10)
                    }
                }
                .padding(.bottom, 5)
            }
            .preferredColorScheme(.light)
    }

}

