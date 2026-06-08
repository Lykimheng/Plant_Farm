//
//  ProfileView.swift
//  PP
//
//  Created by Ly Kimheng on 26/12/25.
//

import SwiftUI

struct ProfileView: View {
    @State private var goNext = false
    @State private var editBtn = false
    var body: some View {
        NavigationStack{
            VStack{
                HStack {
                    Spacer()
                    Text("Account")
                        .font(.title)
                        .bold()
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 15)
                
                HStack(spacing: 40){
                    Button{
                        editBtn = true
                    }
                    label: {
                        ZStack(alignment: .topTrailing){
                            Image("avatar")
                                .resizable()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                            Image(systemName: Constants.cameraIcon)
                                .frame(width: 30, height: 30)
                                .background(Color(.white))
                                .clipShape(Circle())
                                .foregroundStyle(Color(.black))
                                .padding(.top, 80)
                        }
                    }
                    
                    VStack(spacing: 20){
                        Text("Ly Kimheng")
                            .lineLimit(1)
                            .font(.title)
                            .bold()
                            .foregroundStyle(Color(.black))
                        Button{
                            editBtn = true
                        }
                            label: {
                            HStack(spacing: 12) {
                                Text("Edit Profile")
                                    .font(.system(size: 20, weight: .regular))
                                Image(systemName: Constants.editIcon)
                                
                            }
                            .padding()
                            .foregroundColor(.white)
                            .frame(width: 170, height: 50)
                            .background(Color.red.opacity(0.9))
                            .cornerRadius(10)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 50)
                
                
                Navigation(image1: Constants.notificationIcon, name: "Notifaction")
                Navigation(image1: Constants.securityIcon, name: "Security")
                Navigation(image1: Constants.cardIcon, name: "Payment Methods")
                Navigation(image1: Constants.questionIcon, name: "Help and Support")
                
                
                Spacer()
                Button(action: {
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: Constants.LogoutIcon)
                        
                        Text("Logout")
                            .font(.system(size: 20, weight: .regular))
                        
                        Spacer()
                        
                        Image(systemName: Constants.seeMoreIcon)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal,)
                    .frame(height: 50)
                    .background(Color.red)
                    .cornerRadius(10)
                }
                .padding(.horizontal, 10)
            }
            .padding(.bottom, 50)
            .preferredColorScheme(.light)
            .popover(isPresented : $editBtn) {
                EditProfileView()
                    .presentationDetents([.fraction(0.7)])
                    .presentationDragIndicator(.visible)
            }
        }
        
    }
}

#Preview {
    ProfileView()
}
