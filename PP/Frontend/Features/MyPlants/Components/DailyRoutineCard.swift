//
//  DailyRoutineCard.swift
//  PP
//
//  Created by Ly Kimheng on 9/6/26.
//

import SwiftUI

struct DailyTask: Identifiable {
    let id: String
    let title: LocalizedStringResource
    let time: String
    var isDone: Bool = false
}

enum DailyRoutine {
    static let storageKey = "dailyRoutineCompletions"

    private static let times = ["08:00", "10:30", "14:00", "17:30"]

    static func tasks(for plants: [MyPlantModel], completions: String) -> [DailyTask] {
        let generated = plants.prefix(4).enumerated().map { index, plant in
            DailyTask(id: "plant-\(plant.apiId)", title: "Check \(plant.name)", time: times[index % times.count])
        }
        let base = generated.isEmpty
            ? [
                DailyTask(id: "starter-water", title: "Water anything looking dry", time: "08:00"),
                DailyTask(id: "starter-light", title: "Rotate pots toward the light", time: "12:00"),
                DailyTask(id: "starter-leaves", title: "Wipe dust off broad leaves", time: "17:00")
              ]
            : generated

        let done = completedIDs(in: completions)
        return base.map { task in
            var task = task
            task.isDone = done.contains(task.id)
            return task
        }
    }

    static func completions(for tasks: [DailyTask]) -> String {
        "\(todayKey)|\(tasks.filter(\.isDone).map(\.id).joined(separator: ","))"
    }

    private static func completedIDs(in completions: String) -> Set<String> {
        let parts = completions.split(separator: "|", maxSplits: 1).map(String.init)
        guard parts.count == 2, parts[0] == todayKey else { return [] }
        return Set(parts[1].split(separator: ",").map(String.init))
    }

    private static var todayKey: String {
        Date().formatted(.iso8601.year().month().day().dateSeparator(.dash))
    }
}

struct DailyRoutineCard: View {
    @EnvironmentObject private var myPlants: MyPlantsStore
    @AppStorage(DailyRoutine.storageKey) private var completions = ""

    var body: some View {
        let tasks = DailyRoutine.tasks(for: myPlants.plants, completions: completions)
        let remaining = tasks.count { !$0.isDone }

        VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                Text(remaining == 0
                     ? "All done — nice work."
                     : "^[\(remaining) task](inflect: true) left today")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)
                    .contentTransition(.numericText())

                ProgressView(value: Double(tasks.count - remaining), total: Double(max(tasks.count, 1)))
                    .tint(Theme.brand)
            }

            VStack(spacing: 0) {
                ForEach(Array(tasks.enumerated()), id: \.element.id) { index, task in
                    if index > 0 {
                        Divider().overlay(Theme.separator)
                    }
                    row(for: task, in: tasks)
                }
            }
            .cardSurface(padding: Theme.Spacing.lg)
        }
    }

    private func row(for task: DailyTask, in tasks: [DailyTask]) -> some View {
        Button {
            withAnimation(.easeOut(duration: 0.15)) {
                completions = DailyRoutine.completions(for: tasks.map { other in
                    var other = other
                    if other.id == task.id { other.isDone.toggle() }
                    return other
                })
            }
        } label: {
            HStack(spacing: Theme.Spacing.md) {
                Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
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
            .padding(.vertical, Theme.Spacing.sm)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(task.isDone ? .isSelected : [])
    }
}

struct DailyRoutineSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                DailyRoutineCard()
                    .padding(Theme.Spacing.lg)
                    .readableWidth()
                
            }
            .background(Theme.background)
            .navigationTitle("Today's routine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(Theme.background)
    }
}

#Preview {
    Color.clear
        .sheet(isPresented: .constant(true)) { DailyRoutineSheet() }
        .environmentObject(MyPlantsStore())
}
