//
//  HomeView.swift
//  PP
//
//  Created by Ly Kimheng on 24/12/25.
//
import SwiftUI

struct HomeView: View {
    @StateObject private var vm = HomeViewModel()

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255, opacity: 1.0)
                    .ignoresSafeArea()
                VStack(spacing: 20) {
                    HeroSection(searchText: $vm.searchText, isSearching: .constant(false))

                    ScrollView {
                        // ← only show slider when All is selected
                        if vm.selectedCategory == "All" {
                            ImageSliderView()
                                .cornerRadius(16)
                                .padding(.horizontal, 16)
                        }

                        // Category buttons
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                CategoryButton(title: "All",
                                    isSelected: vm.selectedCategory == "All") {
                                    vm.selectedCategory = "All"
                                }
                                CategoryButton(title: "Indoor",
                                    isSelected: vm.selectedCategory == "Indoor") {
                                    vm.selectedCategory = "Indoor"
                                }
                                CategoryButton(title: "Outdoor",
                                    isSelected: vm.selectedCategory == "Outdoor") {
                                    vm.selectedCategory = "Outdoor"
                                }
                                CategoryButton(title: "Big Tree",
                                    isSelected: vm.selectedCategory == "Big Tree") {
                                    vm.selectedCategory = "Big Tree"
                                }
                                CategoryButton(title: "Aquatic",
                                    isSelected: vm.selectedCategory == "Aquatic") {
                                    vm.selectedCategory = "Aquatic"
                                }
                            }
                        }
                        .padding(.leading, 16)

                        // ← switch content based on selected category
                        if !vm.searchText.isEmpty {
                            searchContent
                        } else if vm.selectedCategory == "All" {
                            allContent
                        } else {
                            filteredContent
                        }
                    }
                    .background(Color(.sRGB, red: 246/255, green: 246/255, blue: 246/255, opacity: 1))
                    .padding(.bottom, 80)
                    .ignoresSafeArea(edges: .bottom)
                }
            }
            .preferredColorScheme(.light)
            .navigationDestination(for: PlantModel.self) { plant in
                DetailCard(plant: plant)
            }
            .navigationDestination(for: SpecialPlant.self) { offer in
                DetailSpecialCard(plant: offer)
            }
        }
    }

    // MARK: - All Content
    private var allContent: some View {
        VStack(spacing: 16) {
            TypePlants(
                title: "Special Offer",
                isExpanded: vm.isExpanded("Special"),
                onToggle: { vm.toggleSection("Special") }
            )
            if vm.isExpanded("Special"){
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(SpecialOfferData.all) { plant in
                        NavigationLink(value: plant) {
                            PlantCard(plant: plant)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(SpecialOfferData.all) { plant in
                            NavigationLink(value: plant) {
                                PlantCard(plant: plant)
                            }
                        }
                    }
                }
                .padding(.leading, 16)
                .padding(.bottom, 16)
            }

            VStack(spacing: 20) {
                PopularSection()

                TypePlants(
                    title: "Indoor Plants",
                    isExpanded: vm.isExpanded("Indoor"),
                    onToggle: { vm.toggleSection("Indoor") }
                )
                if vm.isExpanded("Indoor"){
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(PlantData.indoorPlants) { plant in
                            NavigationLink(value: plant) {
                                TypePlantCard(plant: plant)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(PlantData.indoorPlants) { plant in
                                NavigationLink(value: plant) {
                                    TypePlantCard(plant: plant)
                                }
                            }
                        }
                    }
                    .padding(.leading, 16)
                }

                TypePlants(
                    title: "Outdoor Plants",
                    isExpanded: vm.isExpanded("Outdoor"),
                    onToggle: { vm.toggleSection("Outdoor") }
                )
                if vm.isExpanded("Outdoor"){
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(PlantData.outdoorPlants) { plant in
                            NavigationLink(value: plant) {
                                TypePlantCard(plant: plant)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(PlantData.outdoorPlants) { plant in
                                NavigationLink(value: plant) {
                                    TypePlantCard(plant: plant)
                                }
                            }
                        }
                    }
                    .padding(.leading, 16)
                }

                TypePlants(
                    title: "Aquatic Plants",
                    isExpanded: vm.isExpanded("Aquatic"),
                    onToggle: { vm.toggleSection("Aquatic")}
                )
                if vm.isExpanded("Aquatic"){
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(PlantData.aquaticPlants) { plant in
                            NavigationLink(value: plant) {
                                TypePlantCard(plant: plant)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(PlantData.aquaticPlants) { plant in
                                NavigationLink(value: plant) {
                                    TypePlantCard(plant: plant)
                                }
                            }
                        }
                    }
                    .padding(.leading, 16)
                }

                TypePlants(
                    title: "BIG TREE",
                    isExpanded: vm.isExpanded("BigTree"),
                    onToggle: { vm.toggleSection("BigTree")}
                )
                if vm.isExpanded("BigTree"){
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(PlantData.bigTrees) { plant in
                            NavigationLink(value: plant) {
                                TypePlantCard(plant: plant)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(PlantData.bigTrees) { plant in
                                NavigationLink(value: plant) {
                                    TypePlantCard(plant: plant)
                                }
                            }
                        }
                    }
                    .padding(.leading, 16)
                }

                AboutUs()
                Spacer()
                DiscountCard(title: "Membership", subtitle: "Discount 20% for every purchase.")
                DiscountCard(title: "Free 5 coupons", subtitle: "For new user.")
                DiscountCard(title: "Free delivery", subtitle: "For under 3km")
            }
        }
    }

    // MARK: - Filtered Content
    private var filteredContent: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            ForEach(vm.filteredPlants) { plant in
                NavigationLink(value: plant) {
                    TypePlantCard(plant: plant)
                }
            }
        }
        .padding(16)
    }
    private var searchContent: some View {
        VStack(alignment: .leading) {
            Text("Results for \"\(vm.searchText)\"")
                .font(.headline)
                .padding(.horizontal, 16)
                .padding(.top, 8)

            if vm.searchResults.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("No plants found")
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 80)
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(vm.searchResults) { plant in
                        NavigationLink(value: plant) {
                            TypePlantCard(plant: plant)
                        }
                    }
                }
                .padding(16)
            }
        }
    }
}

