//
//  EditProfileView.swift
//  PP
//
//  Created by Ly Kimheng on 26/12/25.
//

import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject private var user: UserStore
    @StateObject private var permission = CameraPermissionManager()
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var isSaving = false
    @State private var isUploadingAvatar = false
    @State private var errorMessage = ""
    @State private var showPhotoSourceDialog = false
    @State private var showImagePicker = false
    @State private var imagePickerSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var selectedImage: UIImage?

    private var hasChanges: Bool {
        !name.trimmed.isEmpty && name.trimmed != user.name
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.xl) {
                    avatarButton

                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        Text("Display name")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Theme.textSecondary)

                        AppTextField(
                            placeholder: "Your name",
                            text: $name,
                            icon: Icons.user,
                            textContentType: .name,
                            submitLabel: .done
                        )
                    }

                    if !errorMessage.isEmpty {
                        Label(errorMessage, systemImage: "exclamationmark.triangle")
                            .font(.system(size: 12.5))
                            .foregroundStyle(Theme.danger)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button {
                        save()
                    } label: {
                        if isSaving {
                            ProgressView().tint(Theme.onBrand)
                        } else {
                            Text("Save changes")
                        }
                    }
                    .buttonStyle(.primary)
                    .disabled(!hasChanges || isSaving)
                }
                .padding(Theme.Spacing.lg)
                .readableWidth(Theme.Layout.compact)
            }
            .background(Theme.background)
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .disabled(isSaving)
                }
            }
        }
        .onAppear { name = user.name }
        .sheet(isPresented: isPickerPresented(for: .photoLibrary)) {
            ImagePicker(selectedImage: $selectedImage, sourceType: .photoLibrary)
                .ignoresSafeArea()
        }
        // the camera needs the whole screen; in a sheet it's cramped, and on iPad
        // it would sit in a small form sheet
        .fullScreenCover(isPresented: isPickerPresented(for: .camera)) {
            ImagePicker(selectedImage: $selectedImage, sourceType: .camera)
                .ignoresSafeArea()
        }
        .onChange(of: selectedImage) { _, newImage in
            guard let newImage else { return }
            uploadAvatar(newImage)
        }
    }

    private var avatarButton: some View {
        Button {
            showPhotoSourceDialog = true
        } label: {
            ZStack(alignment: .bottomTrailing) {
                if isUploadingAvatar {
                    Circle()
                        .fill(Theme.surfaceAlt)
                        .frame(width: 110, height: 110)
                        .overlay(ProgressView())
                } else {
                    UserAvatarView(avatarURL: user.avatarURL, size: 110)
                }

                Image(systemName: Icons.camera)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Theme.onBrand)
                    .frame(width: 32, height: 32)
                    .background(Theme.brand, in: Circle())
                    .overlay(Circle().strokeBorder(Theme.background, lineWidth: 2))
            }
        }
        .buttonStyle(.pressable)
        .disabled(isUploadingAvatar)
        .accessibilityLabel("Change profile photo")
        // attached here so on iPad the popover points at the photo
        .confirmationDialog("Change profile photo", isPresented: $showPhotoSourceDialog, titleVisibility: .visible) {
            Button("Take photo") {
                Task {
                    if await permission.requestCamera() {
                        imagePickerSource = .camera
                        showImagePicker = true
                    } else {
                        errorMessage = "Camera access is off. Enable it in Settings to take a photo."
                    }
                }
            }
            .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))

            Button("Choose from library") {
                Task {
                    if await permission.requestPhotoLibrary() {
                        imagePickerSource = .photoLibrary
                        showImagePicker = true
                    } else {
                        errorMessage = "Photo access is off. Enable it in Settings to pick a photo."
                    }
                }
            }

            Button("Cancel", role: .cancel) {}
        }
    }

    private func isPickerPresented(for source: UIImagePickerController.SourceType) -> Binding<Bool> {
        Binding(
            get: { showImagePicker && imagePickerSource == source },
            set: { showImagePicker = $0 }
        )
    }

    // MARK: - Actions

    private func save() {
        errorMessage = ""
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
    }

    private func uploadAvatar(_ image: UIImage) {
        errorMessage = ""
        isUploadingAvatar = true

        Task {
            let success = await user.uploadAvatar(image)
            isUploadingAvatar = false
            selectedImage = nil
            if !success { errorMessage = user.errorMessage }
        }
    }
}

#Preview {
    EditProfileView()
        .environmentObject(UserStore())
}
