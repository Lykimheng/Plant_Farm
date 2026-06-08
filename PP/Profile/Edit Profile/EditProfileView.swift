//
//  EditProfileView.swift
//  PP
//
//  Created by Ly Kimheng on 26/12/25.
//

import SwiftUI

struct EditProfileView: View {
    @State private var name: String = ""
    @State private var OldPassword: String = ""
    @State private var password: String = ""
    @State private var ConfirmPassword: String = ""
    var body: some View {
        VStack{
            HStack{
                Text("Edit Profile")
                    .font(.title)
                    .bold()
            }
            .padding(.horizontal, )
            Button(action: {
            }) {
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
            HStack{
                Text("Name")
                    .bold()
                
                Spacer()
            }
            .padding(.horizontal,)
            
            NameField(name: $name)
                .padding(.horizontal ,)
                
//            VStack(spacing: 15){
//                OldPasswordField(OldPassword: $OldPassword)
//                InputPasswardField(password: $password)
//                InputPasswardConField(password: $ConfirmPassword)
//            }
//            .padding(.horizontal ,)
            
            Spacer()
            
            Button{
                
            } label: {
                Text("Save")
                    .bold()
            }
            .padding()
            .foregroundColor(.white)
            .frame(width: 170, height: 50)
            .background(Color(.sRGB, red: 32/255, green: 169/255, blue: 172/255, opacity: 1.0))
            .cornerRadius(10)
            
            Spacer()
            
        }
        .padding(.top, 20)
        .preferredColorScheme(.light)
    }
}

#Preview {
    EditProfileView()
}
