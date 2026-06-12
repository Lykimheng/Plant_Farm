//
//  DailyTask.swift
//  PP
//
//  Created by Ly Kimheng on 9/6/26.
//

import SwiftUI

struct DailyTask: Identifiable {
    let id = UUID()
    let title: String
    let time: String
    var isDone: Bool = false
}

struct DailyRoutineCard: View {
    @State private var tasks: [DailyTask] = [
        DailyTask(title: "Water Orchid", time: "08:00 AM", isDone: true),
        DailyTask(title: "Mist Ferns", time: "10:30 AM"),
        DailyTask(title: "Check Monstera", time: "02:00 PM"),
    ]

    var remainingCount: Int {
        tasks.filter { !$0.isDone }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Daily Routine")
                        .font(.headline.bold())
                        .foregroundColor(Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255))
                    Text("\(remainingCount) tasks remaining for today")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            Divider()

            ForEach($tasks) { $task in
                HStack(spacing: 12) {
                    Button {
                        task.isDone.toggle()
                    } label: {
                        Image(systemName: task.isDone ? "checkmark.square.fill" : "square")
                            .foregroundColor(task.isDone ?
                                Color(.sRGB, red: 23/255, green: 105/255, blue: 110/255) :
                                .gray)
                            .font(.title3)
                    }

                    Text(task.title)
                        .font(.subheadline)
                        .strikethrough(task.isDone)
                        .foregroundColor(task.isDone ? .gray : .black)

                    Spacer()

                    Text(task.time)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}
