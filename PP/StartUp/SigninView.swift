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
    var body: some View {
        VStack(spacing: 10) {
            Capsule()
                .frame(width: 40, height: 5)
                .foregroundColor(.gray.opacity(0.4))
                .padding(.top, 8)
            Text("Welcome Back")
                .font(.title)
                .bold()
                .foregroundStyle(Color(.sRGB, red: 32/255, green: 169/255, blue: 172/255, opacity: 1.0))
            Text("Login to your account")
                .font(Font.subheadline.bold())
                .foregroundStyle(Color(.gray))
            ZStack( alignment: .trailing) {
                InputField(icon: Constants.mailIcon, placeholder: "Email", text: $email)
                InputPasswardField(password: $password)
                    .offset(y: 60)
                Button(action: {print("Forget Password?")
                }) {
                    HStack(spacing: 12) {
                        Text("Forget Password?")
                        .font(.system(size: 20, weight: .regular))}
                    .foregroundStyle(Color(.sRGB, red: 32/255, green: 169/255, blue: 172/255, opacity: 1.0))
                    .offset(y: 110)
                }
            }
            .padding(.horizontal,20)
            .padding(.top, 30)
        
            Spacer()
            if !user.errorMessage.isEmpty{
                Text(user.errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal, 20)
            }
            // SIGN IN BUTTON (BOTTOM SHEET)
            Button {
                Task{
                    await user.login(email: email, password: password)
                    if user.isLoggedIn {
                        showLogin = false
                       isLoggedIn = true
                    }
                }
             } label: {
                 if user.isLoading{
                     ProgressView()
                         .frame(width: 200, height: 50)
                 } else{
                     Text("Log in")
                         .font(.system(size: 20, weight: .bold))
                         .foregroundColor(.white)
                         .frame(width: 200, height: 50)
                         .background(Color(.sRGB,
                             red: 32/255,
                             green: 169/255,
                             blue: 172/255))
                         .cornerRadius(10)
                 }
             }
            .padding(.bottom, 5)
            // SIGN UP BUTTON (BOTTOM SHEET)
            HStack(spacing: 10) {
                Text("Don't have an account?")
                    .font(.system(size: 15))
                Button {
                    showSignup = true
                } label: {
                    Text("Sign up")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color(.sRGB, red: 32/255, green: 169/255, blue: 172/255, opacity: 1.0))
                }
            }
            .padding(.bottom, 50)
            Spacer()
        }
        .preferredColorScheme(.light)
        .sheet(isPresented: $showSignup) {
            SignupView()
                .navigationTitle(Text("Sign up"))
        }
    }
}
