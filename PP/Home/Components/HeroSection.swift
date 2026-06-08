//
//  HeroSection.swift
//  PP
//
//  Created by Ly Kimheng on 24/12/25.
//

import SwiftUI

struct HeroSection: View {
    @EnvironmentObject var user: UserModel
    @EnvironmentObject var location: LocationManager
    @Binding var searchText: String
    @Binding var isSearching: Bool
    @Binding var isScanning: Bool
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                HStack(spacing: 8) {
                    Image("avatar")
                        .resizable()
                        .frame(width: 36, height: 36)
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Hi! \(user.name)")
                            .font(.headline)
                            .foregroundColor(.white)

                        Text(location.userAddress.isEmpty ? user.location : location.userAddress)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }

                Spacer()

                HStack(spacing: 16) {
                    Button{
                        
                    } label: {
                        Image(systemName: Constants.favoriteIcon)
                            .foregroundColor(.white)
                    }
                    Button{
                        
                    } label: {
                        Image(systemName: Constants.notificationIcon)
                            .foregroundColor(.white)
                    }
                }
            }

            // Search Bar
            HStack(spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: Constants.searchIcon)
                        .foregroundColor(.gray)

                    TextField("Search plant", text: $searchText)
                        .foregroundColor(.gray)
                        .onTapGesture {
                            isSearching = true
                        }


                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                            isSearching = false
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    } else {
                        Button{
                            isScanning = false
                        } label: {
                            Image(systemName: Constants.scanImageString)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(12)
                .background(Color.white)
                .cornerRadius(22)

            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 16)
        .background(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255, opacity: 1.0))
    }
}
