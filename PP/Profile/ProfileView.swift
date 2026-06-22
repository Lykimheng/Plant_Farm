//
//  ProfileView.swift
//  PP
//
//  Created by Ly Kimheng on 26/12/25.
//
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var user: UserModel
    @EnvironmentObject var orders: OrdersModel
    @EnvironmentObject var wishlist: WishlistModel
    @EnvironmentObject var myPlants: MyPlantsModel
    @State private var showWishlist = false
    @State private var showLogoutAlert = false
    @State private var editBtn = false
    @State private var showMyOrder = false

    var body: some View {
        NavigationStack {
            Group {
                if !user.isLoggedIn {
                    SignInRequiredView(message: "Sign in to manage your profile, orders, and more.")
                } else {
                    profileContent
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.light)
        }
    }

    private var profileContent: some View {
            ScrollView {
                VStack(spacing: 24) {

                    // MARK: - Profile Header
                    VStack(spacing: 12) {
                        ZStack(alignment: .bottomTrailing) {
                            UserAvatarView(avatarURL: user.avatarURL, size: 90)
                                .overlay(
                                    Circle()
                                        .stroke(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255), lineWidth: 2)
                                )

                            Button {
                                editBtn = true
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255))
                                        .frame(width: 26, height: 26)
                                    Image(systemName: "pencil")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                        }

                        Text(user.name)
                            .font(.title3.bold())
                            .foregroundColor(.black)

                        Text(user.email)
                            .font(.subheadline)
                            .foregroundColor(.gray)

                        // membership badge
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255))
                            Text("ITE Member")
                                .font(.caption.bold())
                                .foregroundColor(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255).opacity(0.12))
                        .cornerRadius(20)
                    }
                    .padding(.top, 20)

                    // MARK: - Stats
                    HStack(spacing: 12) {
                        StatCard(title: "My Plants", value: "\(myPlants.plants.count)")
                        StatCard(title: "Care Level", value: myPlants.careLevelText)
                    }
                    .padding(.horizontal)

                    // MARK: - Account Management
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Account Management")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.horizontal)

                        VStack(spacing: 0) {
                            ProfileRow(icon: "bag", title: "My Orders") {
                                showMyOrder = true
                            }
                            Divider().padding(.leading, 56)

                            ProfileRow(icon: "heart", title: "Wishlist") {
                                showWishlist = true
                            }
                            Divider().padding(.leading, 56)

                            ProfileRow(icon: "mappin.circle", title: "Saved Addresses") {
                                // navigate to addresses
                            }
                            Divider().padding(.leading, 56)

                            ProfileRow(icon: "creditcard", title: "Payment Methods") {
                                // navigate to payment
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }

                    // MARK: - App Experience
                    VStack(alignment: .leading, spacing: 8) {
                        Text("App Experience")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.horizontal)

                        VStack(spacing: 0) {
                            ProfileRow(icon: "alarm", title: "Plant Care Reminders") {
                                // navigate to reminders
                            }
                            Divider().padding(.leading, 56)

                            ProfileRow(icon: "gearshape", title: "Settings") {
                                // navigate to settings
                            }
                            Divider().padding(.leading, 56)

                            ProfileRow(icon: "questionmark.circle", title: "Help Center") {
                                // navigate to help
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }

                    // MARK: - Logout
                    Button {
                        showLogoutAlert = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.red)
                            Text("Logout")
                                .font(.headline.bold())
                                .foregroundColor(.red)
                        }
                        .frame(maxWidth: .infinity, minHeight: 54)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }

                    // version
                    Text("Version 2.4.0 • Built for Urban Gardeners")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.bottom, 20)
                }
            }
            .navigationDestination(isPresented: $showMyOrder){
                MyOrdersView()
            }
            // open wishlist as sheet
            .navigationDestination(isPresented: $showWishlist){
                WishlistView()
                    .environmentObject(wishlist)
            }

            .popover(isPresented : $editBtn) {
                EditProfileView()
                    .environmentObject(user)
                    .presentationDetents([.fraction(0.7)])
                    .presentationDragIndicator(.visible)
            }
            // logout confirmation
            .alert("Logout", isPresented: $showLogoutAlert) {
                Button("Logout", role: .destructive) {
                    user.logout()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to logout?")
            }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.title2.bold())
                .foregroundColor(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Profile Row
struct ProfileRow: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray6))
                        .frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .foregroundColor(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255))
                        .font(.system(size: 16))
                }
                Text(title)
                    .foregroundColor(.black)
                    .font(.subheadline)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(UserModel())
        .environmentObject(WishlistModel())
        .environmentObject(OrdersModel())
        .environmentObject(MyPlantsModel())
}
