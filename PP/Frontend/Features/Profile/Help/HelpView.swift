//
//  HelpView.swift
//  PP
//
//  Created by Ly Kimheng on 26/12/25.
//

import SwiftUI

struct HelpView: View {
    var isModal: Bool = false

    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    @State private var expandedTopic: HelpTopic.ID?

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.lg) {
                banner

                SectionCard(title: "Common questions", icon: Icons.help) {
                    VStack(spacing: 0) {
                        ForEach(HelpTopic.all) { topic in
                            HelpRow(
                                topic: topic,
                                isExpanded: expandedTopic == topic.id
                            ) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    expandedTopic = expandedTopic == topic.id ? nil : topic.id
                                }
                            }

                            if topic.id != HelpTopic.all.last?.id {
                                Divider().overlay(Theme.separator)
                            }
                        }
                    }
                }

                SectionCard(title: "Still need help?", icon: Icons.message) {
                    VStack(spacing: Theme.Spacing.md) {
                        contactRow(
                            icon: Icons.mail,
                            title: "Email support",
                            detail: HelpContact.email,
                            url: URL(string: "mailto:\(HelpContact.email)")
                        )
                        Divider().overlay(Theme.separator)
                        contactRow(
                            icon: Icons.phone,
                            title: "Call the shop",
                            detail: HelpContact.phoneDisplay,
                            url: URL(string: "tel://\(HelpContact.phoneDial)")
                        )
                    }
                }
            }
            .padding(Theme.Spacing.lg)
            .readableWidth()
        }
        .background(Theme.background)
        .navigationTitle("Help Center")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isModal {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var banner: some View {
        VStack(spacing: Theme.Spacing.sm) {
            Image(systemName: Icons.myPlants)
                .font(.system(size: 30, weight: .light))
                .foregroundStyle(Theme.brand)

            Text("How can we help?")
                .font(.system(size: 19, weight: .bold))
                .foregroundStyle(Theme.textPrimary)

            Text("Answers to the questions we get most, and a way to reach us if yours isn't here.")
                .font(.system(size: 13))
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.Spacing.xl)
        .background(Theme.sectionWash, in: RoundedRectangle(cornerRadius: Theme.Radius.lg, style: .continuous))
    }

    private func contactRow(icon: String, title: LocalizedStringResource, detail: String, url: URL?) -> some View {
        Button {
            if let url { openURL(url) }
        } label: {
            HStack(spacing: Theme.Spacing.md) {
                SettingsIcon(icon)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Theme.textPrimary)
                    Text(detail)
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.textSecondary)
                }
                Spacer()
                Image(systemName: Icons.forward)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Theme.textTertiary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(url == nil)
    }
}

// MARK: - Content

enum HelpContact {
    static let email = "support@plantfarm.app"
    static let phoneDisplay = "+855 23 999 123"
    static let phoneDial = "+85523999123"
}

struct HelpTopic: Identifiable {
    let id = UUID()
    let icon: String
    let question: LocalizedStringResource
    let answer: LocalizedStringResource

    static let all: [HelpTopic] = [
        HelpTopic(
            icon: Icons.truck,
            question: "How long does delivery take?",
            answer: "Standard delivery arrives in 3–5 days for \(DeliveryOption.standard.fee.priceText). Express arrives the next day for \(DeliveryOption.express.fee.priceText). Both are free on membership orders over $50."
        ),
        HelpTopic(
            icon: Icons.waterFilled,
            question: "How often should I water a new plant?",
            answer: "Most indoor plants want a drink when the top 2 cm of soil is dry — usually once a week. Succulents and cacti prefer every two to three weeks. Each plant's detail page lists its own schedule."
        ),
        HelpTopic(
            icon: Icons.bag,
            question: "Can I cancel or change an order?",
            answer: "Yes, while an order is still pending. Open Profile → My Orders, choose the order and tap Cancel order. Once the shop confirms it and starts preparing, cancelling is no longer possible — email us and we'll help."
        ),
        HelpTopic(
            icon: Icons.myPlants,
            question: "My plant arrived damaged. What now?",
            answer: "Send a photo within 48 hours of delivery and we'll replace it on the next run at no cost. Leaves sometimes bruise in transit — most plants recover within a fortnight, and we'd rather advise than replace unnecessarily."
        ),
        HelpTopic(
            icon: Icons.star,
            question: "Who can leave a review?",
            answer: "Anyone signed in can rate and review a plant, and you can edit or delete your own review at any time from the plant's page."
        )
    ]
}

private struct HelpRow: View {
    let topic: HelpTopic
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Button(action: onTap) {
                HStack(spacing: Theme.Spacing.md) {
                    Image(systemName: topic.icon)
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.brand)
                        .frame(width: 22)

                    Text(topic.question)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Theme.textPrimary)
                        .multilineTextAlignment(.leading)

                    Spacer(minLength: Theme.Spacing.sm)

                    Image(systemName: Icons.collapse)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Theme.textTertiary)
                        .rotationEffect(.degrees(isExpanded ? 0 : 180))
                }
                .padding(.vertical, Theme.Spacing.md)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                Text(topic.answer)
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.textSecondary)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.leading, 34)
                    .padding(.bottom, Theme.Spacing.md)
            }
        }
    }
}

#Preview {
    NavigationStack { HelpView() }
}
