//
//  MyPlantsView.swift
//  PP
//
//  Created by Ly Kimheng on 26/12/25.
//

import SwiftUI

struct MyPlantsView: View {
    @EnvironmentObject private var myPlants: MyPlantsStore
    @EnvironmentObject private var user: UserStore
    @EnvironmentObject private var catalog: PlantsStore

    @State private var selectedDate = Date()
    @State private var showAddPlant = false

    var body: some View {
        Group {
            if user.isLoggedIn {
                content
            } else {
                SignInRequiredView(message: "Sign in to track and care for your plants.")
            }
        }
        .background(Theme.background)
        .navigationTitle("My Plants")
        .navigationBarTitleDisplayMode(.large)
    }

    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                Text("Manage your garden's health and care schedule.")
                    .font(.system(size: 13.5))
                    .foregroundStyle(Theme.textSecondary)
                    .padding(.horizontal, Theme.Spacing.lg)

                WeekStrip(selectedDate: $selectedDate)
                    .padding(.horizontal, Theme.Spacing.lg)

                plantList

                DailyRoutineCard()
                    .padding(.horizontal, Theme.Spacing.lg)
            }
            .padding(.top, Theme.Spacing.md)
            .padding(.bottom, 88)
            .readableWidth()
        }
        .refreshable { await myPlants.load(userId: user.id) }
        .overlay(alignment: .bottomTrailing) { addButton }
        .sheet(isPresented: $showAddPlant) {
            AddMyPlantView()
        }
        .task { await myPlants.loadIfNeeded(userId: user.id) }
    }

    @ViewBuilder
    private var plantList: some View {
        if myPlants.isLoading && myPlants.isEmpty {
            SkeletonList(count: 2, height: 240)
                .padding(.horizontal, Theme.Spacing.lg)
        } else if myPlants.isEmpty {
            EmptyStateView(
                icon: Icons.leaf,
                title: "No plants yet",
                message: "Add a plant from the shop catalog to start tracking its watering schedule.",
                actionTitle: "Add a plant",
                action: { showAddPlant = true }
            )
        } else {
            LazyVStack(spacing: Theme.Spacing.lg) {
                ForEach(myPlants.plants) { plant in
                    MyPlantCard(plant: plant) {
                        Task { await myPlants.remove(plant, userId: user.id) }
                    }
                }
            }
            .padding(.horizontal, Theme.Spacing.lg)
        }
    }

    private var addButton: some View {
        Button {
            showAddPlant = true
        } label: {
            Image(systemName: Icons.plus)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Theme.onBrand)
                .frame(width: 56, height: 56)
                .background(Theme.brand, in: Circle())
                .softShadow(radius: 12, y: 6)
        }
        .buttonStyle(.pressable)
        .padding(Theme.Spacing.lg)
        .accessibilityLabel("Add a plant")
    }
}

// MARK: - Week strip

struct WeekStrip: View {
    @Binding var selectedDate: Date

    private let calendar = Calendar.current

    private var weekDates: [Date] {
        let today = Date()
        guard let interval = calendar.dateInterval(of: .weekOfYear, for: today) else { return [today] }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: interval.start) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text(selectedDate.formatted(.dateTime.month(.wide).year()))
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Theme.brand)

            HStack(spacing: Theme.Spacing.sm) {
                ForEach(weekDates, id: \.self) { date in
                    dayCell(date)
                }
            }
        }
    }

    private func dayCell(_ date: Date) -> some View {
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(date)

        return Button {
            withAnimation(.easeOut(duration: 0.15)) { selectedDate = date }
        } label: {
            VStack(spacing: 3) {
                Text(date.formatted(.dateTime.weekday(.abbreviated)))
                    .font(.system(size: 10.5))
                    .foregroundStyle(isSelected ? Theme.onBrand.opacity(0.85) : Theme.textTertiary)

                Text(date.formatted(.dateTime.day()))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(isSelected ? Theme.onBrand : Theme.textPrimary)

                Circle()
                    .fill(isToday ? (isSelected ? Theme.onBrand : Theme.brand) : .clear)
                    .frame(width: 4, height: 4)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.sm)
            .background(
                isSelected ? Theme.brand : Theme.surface,
                in: RoundedRectangle(cornerRadius: Theme.Radius.sm, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.sm, style: .continuous)
                    .strokeBorder(isSelected ? .clear : Theme.separator, lineWidth: 0.7)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(date.formatted(date: .complete, time: .omitted))
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

#Preview {
    NavigationStack {
        MyPlantsView()
            .environmentObject(MyPlantsStore())
            .environmentObject(UserStore())
            .environmentObject(PlantsStore())
    }
}
