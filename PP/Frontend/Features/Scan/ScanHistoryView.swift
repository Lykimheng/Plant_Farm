//
//  ScanHistoryView.swift
//  PP
//
//  Created by Ly Kimheng on 8/10/26.
//

import SwiftUI

enum ScanRoute: Hashable {
    case history
}

struct ScanHistoryView: View {
    @EnvironmentObject private var history: ScanHistoryStore
    @State private var showClearConfirm = false

    var body: some View {
        Group {
            if history.isEmpty {
                EmptyStateView(
                    icon: Icons.history,
                    title: "No scans yet",
                    message: "Plants you identify with the camera or from your photos will show up here."
                )
                .frame(maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: Theme.Spacing.md) {
                        ForEach(history.records) { record in
                            NavigationLink(value: record) {
                                ScanHistoryRow(record: record, image: history.image(for: record))
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button("Delete", systemImage: Icons.trash, role: .destructive) {
                                    withAnimation { history.remove(record) }
                                }
                            }
                        }
                    }
                    .padding(Theme.Spacing.lg)
                    .readableWidth()
                }
            }
        }
        .background(Theme.background)
        .navigationTitle("Scan history")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !history.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Clear", role: .destructive) { showClearConfirm = true }
                        .tint(Theme.danger)
                        .confirmationDialog(
                            "Clear scan history?",
                            isPresented: $showClearConfirm,
                            titleVisibility: .visible
                        ) {
                            Button("Clear all", role: .destructive) {
                                withAnimation { history.clear() }
                            }
                            Button("Cancel", role: .cancel) {}
                        } message: {
                            Text("All saved scans and their photos will be removed from this device.")
                        }
                }
            }
        }
    }
}

private struct ScanHistoryRow: View {
    let record: ScanRecord
    let image: UIImage?

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            thumbnail

            VStack(alignment: .leading, spacing: 3) {
                if let best = record.predictions.first {
                    Text(best.species.displayName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)
                        .lineLimit(1)
                    Text("\(best.percentText) match")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.textSecondary)
                }

                if let verdict = record.healthPredictions.first {
                    let isHealthy = verdict.symptom == .healthy
                    Label {
                        Text(verdict.symptom.displayName)
                    } icon: {
                        Image(systemName: isHealthy ? Icons.verified : Icons.warning)
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(isHealthy ? Theme.success : Theme.warning)
                    .lineLimit(1)
                }

                Text(record.date, format: .relative(presentation: .named))
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.textTertiary)
            }

            Spacer(minLength: 0)

            Image(systemName: Icons.forward)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Theme.textTertiary)
        }
        .cardSurface(padding: Theme.Spacing.md)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }

    private var thumbnail: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Theme.surfaceAlt
                    .overlay(Image(systemName: Icons.leaf).foregroundStyle(Theme.textTertiary))
            }
        }
        .frame(width: 64, height: 64)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.sm, style: .continuous))
        .accessibilityHidden(true)
    }
}

struct ScanRecordDetailView: View {
    let record: ScanRecord

    @EnvironmentObject private var history: ScanHistoryStore
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ScanViewModel

    init(record: ScanRecord, image: UIImage?) {
        self.record = record
        _viewModel = StateObject(wrappedValue: ScanViewModel(record: record, image: image))
    }

    var body: some View {
        ScanResultContent(viewModel: viewModel)
            .navigationTitle(Text(record.date, format: .dateTime.day().month().hour().minute()))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Delete", systemImage: Icons.trash, role: .destructive) {
                        history.remove(record)
                        dismiss()
                    }
                    .tint(Theme.danger)
                }
            }
    }
}

#Preview {
    NavigationStack {
        ScanHistoryView()
            .environmentObject(ScanHistoryStore())
            .environmentObject(PlantsStore())
            .environmentObject(CartStore())
            .environmentObject(WishlistStore())
    }
}
