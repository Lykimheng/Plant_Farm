//
//  DailyRoutineCard.swift
//  PP
//
//  Created by Ly Kimheng on 9/6/26.
//

import SwiftUI

struct DailyTask: Identifiable, Hashable {
    let id: String
    let title: String
    let time: String
    var isDone: Bool = false
}

struct DailyRoutineCard: View {
    @EnvironmentObject private var myPlants: MyPlantsStore

    @AppStorage("dailyRoutineCompletions") private var completionsData = ""

    @State private var tasks: [DailyTask] = []

    private var remaining: Int { tasks.count { !$0.isDone } }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack(spacing: Theme.Spacing.sm) {
                Image(systemName: "checklist")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.brand)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Today's routine")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Theme.textPrimary)
                    Text(remaining == 0
                         ? "All done — nice work."
                         : "^[\(remaining) task](inflect: true) left today")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.textSecondary)
                }

                Spacer()
            }

            Divider().overlay(Theme.separator)

            ForEach($tasks) { $task in
                Button {
                    withAnimation(.easeOut(duration: 0.15)) {
                        task.isDone.toggle()
                        persist()
                    }
                } label: {
                    HStack(spacing: Theme.Spacing.md) {
                        Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 19))
                            .foregroundStyle(task.isDone ? Theme.brand : Theme.textTertiary)

                        Text(task.title)
                            .font(.system(size: 14))
                            .strikethrough(task.isDone)
                            .foregroundStyle(task.isDone ? Theme.textTertiary : Theme.textPrimary)

                        Spacer()

                        Text(task.time)
                            .font(.system(size: 11.5))
                            .foregroundStyle(Theme.textTertiary)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .cardSurface(padding: Theme.Spacing.lg)
        .onAppear(perform: buildTasks)
        .onChange(of: myPlants.plants) { _, _ in buildTasks() }
    }

    // MARK: - Tasks

    private func buildTasks() {
        let done = completedIDsForToday()

        let generated: [DailyTask] = myPlants.plants.prefix(4).enumerated().map { index, plant in
            DailyTask(
                id: "plant-\(plant.apiId)",
                title: "Check \(plant.name)",
                time: ["08:00", "10:30", "14:00", "17:30"][index % 4]
            )
        }

        let base = generated.isEmpty
            ? [
                DailyTask(id: "starter-water", title: "Water anything looking dry", time: "08:00"),
                DailyTask(id: "starter-light", title: "Rotate pots toward the light", time: "12:00"),
                DailyTask(id: "starter-leaves", title: "Wipe dust off broad leaves", time: "17:00")
              ]
            : generated

        tasks = base.map { task in
            var copy = task
            copy.isDone = done.contains(task.id)
            return copy
        }
    }

    // MARK: - Persistence

    private func completedIDsForToday() -> Set<String> {
        let parts = completionsData.split(separator: "|", maxSplits: 1).map(String.init)
        guard parts.count == 2, parts[0] == Self.todayKey else { return [] }
        return Set(parts[1].split(separator: ",").map(String.init))
    }

    private func persist() {
        let done = tasks.filter(\.isDone).map(\.id).joined(separator: ",")
        completionsData = "\(Self.todayKey)|\(done)"
    }

    private static var todayKey: String {
        Date().formatted(.iso8601.year().month().day().dateSeparator(.dash))
    }
}

#Preview {
    DailyRoutineCard()
        .environmentObject(MyPlantsStore())
        .padding()
        .background(Theme.background)
}
