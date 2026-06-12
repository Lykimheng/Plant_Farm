//
//  MyPlantView.swift
//  PP
//
//  Created by Ly Kimheng on 26/12/25.
//
import SwiftUI

struct MyPlantView: View {
    @EnvironmentObject var myPlants: MyPlantsModel
    @State private var selectedDate = Date()
    @State private var showAddPlant = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // subtitle
                    Text("Manage your garden's health and care schedule.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.horizontal)

                    // MARK: - Date Picker
                    MonthCalendarView(selectedDate: $selectedDate)
                        .padding(.horizontal)

                    // MARK: - Plant Cards
                    if myPlants.plants.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "leaf")
                                .font(.system(size: 60))
                                .foregroundColor(.gray.opacity(0.4))
                            Text("No plants yet")
                                .font(.title3)
                                .foregroundColor(.gray)
                            Text("Tap + to add your first plant")
                                .font(.caption)
                                .foregroundColor(.gray.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                    } else {
                        VStack(spacing: 16) {
                            ForEach(myPlants.plants) { plant in
                                MyPlantCard(plant: plant) {
                                    myPlants.removePlant(plant)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    // MARK: - Daily Routine
                    DailyRoutineCard()
                        .padding(.horizontal)
                        .padding(.bottom, 80)
                }
                .padding(.top, 8)
            }
            .background(Color(.systemGray6))
            .navigationTitle("My Plants")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.light)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { } label: {
                        Image(systemName: "calendar.badge.clock")
                            .foregroundColor(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255))
                    }
                }
            }
            // MARK: - Add button
            .overlay(
                Button {
                    showAddPlant = true
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255))
                            .frame(width: 56, height: 56)
                            .shadow(radius: 6)
                        Image(systemName: "plus")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                    }
                }
                .padding(.trailing, 20)
                .padding(.bottom, 90),
                alignment: .bottomTrailing
            )
            .sheet(isPresented: $showAddPlant) {
                AddMyPlantView()
                    .environmentObject(myPlants)
            }
        }
    }
}

// MARK: - Simple month calendar
struct MonthCalendarView: View {
    @Binding var selectedDate: Date
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f
    }()

    var weekDates: [Date] {
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let startOfWeek = calendar.date(byAdding: .day, value: -(weekday - 2), to: today) ?? today
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(dateFormatter.string(from: selectedDate))
                    .font(.title3.bold())
                    .foregroundColor(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255))
                Spacer()
                Button { } label: {
                    Image(systemName: "calendar")
                        .foregroundColor(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255))
                }
            }

            HStack(spacing: 8) {
                ForEach(weekDates, id: \.self) { date in
                    let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                    let isToday = calendar.isDateInToday(date)

                    Button {
                        selectedDate = date
                    } label: {
                        VStack(spacing: 4) {
                            Text(dayLetter(date))
                                .font(.caption2)
                                .foregroundColor(isSelected ? .white : .gray)
                            Text(dayNumber(date))
                                .font(.subheadline.bold())
                                .foregroundColor(isSelected ? .white : .black)
                            if isToday {
                                Circle()
                                    .fill(isSelected ? Color.white : Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255))
                                    .frame(width: 4, height: 4)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            isSelected ?
                            Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255) :
                            Color.white
                        )
                        .cornerRadius(10)
                    }
                }
            }
        }
    }

    func dayLetter(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "EEE"
        return f.string(from: date)
    }

    func dayNumber(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "d"
        return f.string(from: date)
    }
}
