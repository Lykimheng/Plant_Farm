//
//  StartScreen.swift
//  PP
//
//  Created by Ly Kimheng on 25/12/25.
//
//

import SwiftUI

struct StartScreen: View {
    @Binding var isLoggedIn: Bool
    @State private var showLogin = false
    @State private var showSignup = false
    var body: some View {
            ZStack {
                Image("Background")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack {
                    Text("The best\napp for\nyour plants")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.white)
                        .padding()
                        .position(x: 140, y: 220)
                    
                    
                    // SIGN IN BUTTON (BOTTOM SHEET)
                    Button {
                        showLogin = true
                    } label: {
                        Text("Sign in")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(Color(.sRGB, red: 32/255, green: 169/255, blue: 172/255, opacity: 1.0))
                            .cornerRadius(10)
                    }
                    .padding(.bottom, 5)
                    
                    // SIGN UP BUTTON (BOTTOM SHEET)
                    HStack(spacing: 10) {
                        Text("Create an account?")
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                        
                        Button {
                            showSignup = true
                        } label: {
                            Text("Sign up")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(Color(.sRGB, red: 32/255, green: 169/255, blue: 172/255, opacity: 1.0))
                        }
                    }
                    .padding(.bottom, 50)
                }
            }
            .preferredColorScheme(.light)
            .navigationDestination(isPresented: $isLoggedIn) {
                ContentView()
            }
            .sheet(isPresented: $showLogin) {
                SigninView(
                    isLoggedIn: $isLoggedIn,
                    showLogin: $showLogin
                )
                .presentationDetents([.fraction(0.7)])
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showSignup) {
                SignupView()
                    .navigationTitle(Text("Sign up"))
                    .presentationDetents([.fraction(0.8)])
                    .presentationDragIndicator(.visible)
        }
    }
}
