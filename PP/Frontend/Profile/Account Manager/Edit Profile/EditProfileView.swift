//
//  EditProfileView.swift
//  PP
//
//  Created by Ly Kimheng on 26/12/25.
//

import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var user: UserModel
    @StateObject private var permission = CameraPermissionManager()
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var isSaving = false
    @State private var isUploadingAvatar = false
    @State private var errorMessage = ""
    @State private var showPhotoSourceDialog = false
    @State private var showImagePicker = false
    @State private var imagePickerSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var selectedImage: UIImage?

    var body: some View {
        VStack {
            HStack{
                Text("Edit Profile")
                    .font(.title)
                    .bold()
            }
            .padding(.horizontal)

            Button {
                showPhotoSourceDialog = true
            } label: {
                ZStack(alignment: .bottomTrailing) {
                    if isUploadingAvatar {
                        Circle()
                            .fill(Color(.systemGray5))
                            .frame(width: 120, height: 120)
                            .overlay(ProgressView())
                    } else {
                        UserAvatarView(avatarURL: user.avatarURL, size: 120)
                    }
                    ZStack {
                        Circle()
                            .fill(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255))
                            .frame(width: 32, height: 32)
                        Image(systemName: Constants.cameraIcon)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.top, 8)

            HStack{
                Text("Name")
                    .bold()

                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 16)

            NameField(name: $name)
                .padding(.horizontal)

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }

            Spacer()

            Button{
                guard !name.isEmpty else { return }
                isSaving = true
                Task {
                    let success = await user.updateProfile(name: name)
                    isSaving = false
                    if success {
                        dismiss()
                    } else {
                        errorMessage = user.errorMessage
                    }
                }
            } label: {
                if isSaving {
                    ProgressView()
                        .frame(width: 170, height: 50)
                } else {
                    Text("Save")
                        .bold()
                        .foregroundColor(.white)
                        .frame(width: 170, height: 50)
                }
            }
            .disabled(name.isEmpty || isSaving)
            .background(Color(.sRGB, red: 32/255, green: 169/255, blue: 172/255, opacity: 1.0))
            .cornerRadius(10)

            Spacer()

        }
        .padding(.top, 20)
        .preferredColorScheme(.light)
        .onAppear {
            name = user.name
        }
        .confirmationDialog("Change Profile Photo", isPresented: $showPhotoSourceDialog) {
            Button("Take Photo") {
                permission.requestCameraPermission { granted in
                    if granted {
                        imagePickerSource = .camera
                        showImagePicker = true
                    }
                }
            }
            Button("Choose from Library") {
                permission.requestPhotoPermission { granted in
                    if granted {
                        imagePickerSource = .photoLibrary
                        showImagePicker = true
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage, sourceType: imagePickerSource)
        }
        .onChange(of: selectedImage) { _, newImage in
            guard let newImage else { return }
            isUploadingAvatar = true
            Task {
                let success = await user.uploadAvatar(newImage)
                isUploadingAvatar = false
                if !success {
                    errorMessage = user.errorMessage
                }
                selectedImage = nil
            }
        }
    }
}

#Preview {
    EditProfileView()
        .environmentObject(UserModel())
}
