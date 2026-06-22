//
//  SigninView.swift
//  PP
//
//  Created by Ly Kimheng on 26/12/25.
//

import SwiftUI
import Combine

struct SigninView: View {
    
    @Binding var isLoggedIn: Bool
    @Binding var showLogin: Bool
    @EnvironmentObject var user: UserModel
    
    @State private var email = ""
    @State private var password = ""
    @State private var showSignup = false
    @State private var forgetPassword = false
    var body: some View {
        VStack(spacing: 10) {
            Text("Welcome Back")
                .font(.title.bold())
                .foregroundStyle(Color(.sRGB, red: 32/255, green: 169/255, blue: 172/255))
            
            Text("Login to your account")
                .font(.subheadline.bold())
                .foregroundStyle(Color.gray)
            
            VStack(spacing: 16) {
                InputField(icon: Constants.mailIcon, placeholder: "Email", text: $email)
                InputPasswardField(password: $password)
                
                HStack {
                    Spacer()
                    Button {
                        forgetPassword = true
                    } label: {
                        Text("Forget Password?")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(Color(.sRGB, red: 32/255, green: 169/255, blue: 172/255))
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 30)
            
            Spacer()
            
            if !user.errorMessage.isEmpty {
                Text(user.errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal, 20)
            }
            
            Button {
                Task {
                    await user.login(email: email, password: password)
                    if user.isLoggedIn {
                        showLogin = false
                        isLoggedIn = true
                    }
                }
            } label: {
                if user.isLoading {
                    ProgressView()
                        .frame(width: 200, height: 50)
                } else {
                    Text("Log in")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color(.sRGB, red: 32/255, green: 169/255, blue: 172/255))
                        .cornerRadius(10)
                }
            }
            .padding(.bottom, 5)
            
            HStack(spacing: 10) {
                Text("Don't have an account?")
                    .font(.system(size: 15))
                Button {
                    showSignup = true
                } label: {
                    Text("Sign up")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color(.sRGB, red: 32/255, green: 169/255, blue: 172/255))
                }
            }
            .padding(.bottom, 50)
            
            Spacer()
        }
        .preferredColorScheme(.light)
        .sheet(isPresented: $forgetPassword) {
            ForgetPassword()
                .environmentObject(user)
                .presentationDetents([.fraction(0.7)])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showSignup) {
            SignupView()
                .navigationTitle(Text("Sign up"))
                .presentationDetents([.fraction(0.9)])
                .presentationDragIndicator(.visible)
        }
        .padding(.top, 20)
    }
}
