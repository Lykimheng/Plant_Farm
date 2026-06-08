//
//  HomeView.swift
//  PP
//
//  Created by Ly Kimheng on 24/12/25.
//
import SwiftUI

struct HomeView: View {
    @State private var selectedCategory = "All"    // ← add this
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var isScanning = false
    @State private var expandedSection: Set<String> = []
    
    func isExpanded(_ section: String) -> Bool{
        expandedSection.contains(section)
    }
    func toggleSection(_ section: String) {
        if expandedSection.contains(section) {
            expandedSection.remove(section)
        } else {
            expandedSection.insert(section)
        }
    }
    
    var searchResults: [PlantModel] {
        let all = PlantData.indoorPlants + PlantData.outdoorPlants + PlantData.aquaticPlants + PlantData.bigTrees
        if searchText.isEmpty { return [] }
        return all.filter{
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.type.localizedCaseInsensitiveContains(searchText)
        }
    }
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255, opacity: 1.0)
                    .ignoresSafeArea()
                VStack(spacing: 20) {
                    HeroSection(searchText: $searchText, isSearching: $isSearching, isScanning: $isScanning)

                    ScrollView {
                        // ← only show slider when All is selected
                        if selectedCategory == "All" {
                            ImageSliderView()
                                .cornerRadius(16)
                                .padding(.horizontal, 16)
                        }

                        // Category buttons
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                CategoryButton(title: "All",
                                    isSelected: selectedCategory == "All") {
                                    selectedCategory = "All"
                                }
                                CategoryButton(title: "Indoor",
                                    isSelected: selectedCategory == "Indoor") {
                                    selectedCategory = "Indoor"
                                }
                                CategoryButton(title: "Outdoor",
                                    isSelected: selectedCategory == "Outdoor") {
                                    selectedCategory = "Outdoor"
                                }
                                CategoryButton(title: "Big Tree",
                                    isSelected: selectedCategory == "Big Tree") {
                                    selectedCategory = "Big Tree"
                                }
                                CategoryButton(title: "Aquatic",
                                    isSelected: selectedCategory == "Aquatic") {
                                    selectedCategory = "Aquatic"
                                }
                            }
                        }
                        .padding(.leading, 16)

                        // ← switch content based on selected category
                        if !searchText.isEmpty {
                            searchContent
                        } else if selectedCategory == "All" {
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
            TypePlants(title: "Special Offer")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(SpecialOfferData.all) { plant in
                        NavigationLink(value: plant) {
                            PlantCard(plant: plant)
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
                    isExpanded: isExpanded("Indoor"),
                    onToggle: { toggleSection("Indoor") }
                )
                if isExpanded("Indoor"){
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
                    isExpanded: isExpanded("Outdoor"),
                    onToggle: { toggleSection("Outdoor") }
                )
                if isExpanded("Outdoor"){
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
                    isExpanded: isExpanded("Aquatic"),
                    onToggle: { toggleSection("Aquatic")}
                )
                if isExpanded("Aquatic"){
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
                    isExpanded: isExpanded("BigTree"),
                    onToggle: { toggleSection("BigTree")}
                )
                if isExpanded("BigTree"){
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
        let plants: [PlantModel] = {
            switch selectedCategory {
            case "Indoor":   return PlantData.indoorPlants
            case "Outdoor":  return PlantData.outdoorPlants
            case "Aquatic":  return PlantData.aquaticPlants
            case "Big Tree": return PlantData.bigTrees
            default:         return []
            }
        }()

        return LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            ForEach(plants) { plant in
                NavigationLink(value: plant) {
                    TypePlantCard(plant: plant)
                }
            }
        }
        .padding(16)
    }
    private var searchContent: some View {
        VStack(alignment: .leading) {
            Text("Results for \"\(searchText)\"")
                .font(.headline)
                .padding(.horizontal, 16)
                .padding(.top, 8)

            if searchResults.isEmpty {
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
                    ForEach(searchResults) { plant in
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

