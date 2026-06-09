//
//  EditProfileView.swift
//  PP
//
//  Created by Ly Kimheng on 26/12/25.
//

import SwiftUI
import AVFoundation

struct EditProfileView: View {
    @StateObject private var camera = CameraViewModel()
    @StateObject private var permission = CameraPermissionManager()
    @State private var name: String = ""
    @State private var OldPassword: String = ""
    @State private var password: String = ""
    @State private var ConfirmPassword: String = ""
    @State private var showPhotoLibrary: Bool = false
    @State private var selectedImage: UIImage? = nil 
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
                    Button{
                        permission.requestPhotoPermission { granted in
                            if granted {
                                showPhotoLibrary = true
                            }
                        }
                    } label: {
                        Image(systemName: Constants.cameraIcon)
                            .frame(width: 30, height: 30)
                            .background(Color(.white))
                            .clipShape(Circle())
                            .foregroundStyle(Color(.black))
                            .padding(.top, 80)
                    }
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
        .sheet(isPresented: $showPhotoLibrary) {
            ImagePicker(selectedImage: $selectedImage, sourceType: .photoLibrary)
        }
        .preferredColorScheme(.light)
    }
}

#Preview {
    EditProfileView()
}
