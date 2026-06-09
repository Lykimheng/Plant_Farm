//
//  ForgetPassward.swift
//  PP
//
//  Created by Ly Kimheng on 27/12/25.
//

import SwiftUI

struct ForgetPassword: View {
    @EnvironmentObject var user: UserModel
    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isSuccess = false

    var body: some View {
        VStack(spacing: 24) {
            // header
            VStack(spacing: 8) {
                Image(systemName: "lock.rotation")
                    .font(.system(size: 60))
                    .foregroundColor(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255))

                Text("Reset Password")
                    .font(.title2.bold())

                Text("Enter your email and new password")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)

            VStack(spacing: 16) {
                InputField(icon: Constants.mailIcon,
                          placeholder: "Email",
                          text: $email)

                InputPasswardField(password: $newPassword)

                InputPasswardConField(password: $confirmPassword)
            }
            .padding(.horizontal, 20)

            // error or success message
            if !user.errorMessage.isEmpty {
                Text(user.errorMessage)
                    .font(.caption)
                    .foregroundColor(isSuccess ? .green : .red)
                    .padding(.horizontal, 20)
            }

            Spacer()

            // reset button
            Button {
                guard newPassword == confirmPassword else {
                    user.errorMessage = "Passwords do not match."
                    return
                }
                guard newPassword.count >= 6 else {
                    user.errorMessage = "Password must be at least 6 characters."
                    return
                }
                Task {
                    await user.forgotPassword(
                        email: email,
                        newPassword: newPassword
                    )
                    if user.errorMessage == "Password updated successfully." {
                        isSuccess = true
                        // go back after 1.5 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            dismiss()
                        }
                    }
                }
            } label: {
                if user.isLoading {
                    ProgressView()
                        .frame(width: 200, height: 50)
                } else {
                    Text("Reset Password")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color(.sRGB, red: 32/255, green: 169/255, blue: 172/255))
                        .cornerRadius(10)
                }
            }
            .padding(.bottom, 40)
        }
        .preferredColorScheme(.light)
        .onDisappear {
            user.errorMessage = ""    // ← clear message when leaving
        }
    }
}

#Preview {
    ForgetPassword()
        .environmentObject(UserModel())
}
