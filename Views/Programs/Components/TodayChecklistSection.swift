//
//  TodayChecklistSection.swift
//  FUUD
//
//  チェックリストセクション
//  Phase 6-UI: TodayProgramView用
//

import SwiftUI

struct TodayChecklistSection: View {
    @Binding var items: [TodayChecklistItem]
    let onToggle: (TodayChecklistItem) -> Void

    private var completedCount: Int {
        items.filter { $0.isCompleted }.count
    }

    private var totalCount: Int {
        items.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            // Section Header
            HStack {
                Text("TODAY'S CHECKLIST")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)

                Spacer()

                // Progress
                Text("\(completedCount)/\(totalCount)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.lifesumDarkGreen)
            }
            .padding(.horizontal, VirgilSpacing.md)

            // Checklist Items
            VStack(spacing: VirgilSpacing.sm) {
                ForEach(items) { item in
                    ChecklistItemRow(
                        item: item,
                        onToggle: { onToggle(item) }
                    )
                }
            }
            .padding(.horizontal, VirgilSpacing.md)
        }
    }
}

// MARK: - Checklist Item Row

struct ChecklistItemRow: View {
    let item: TodayChecklistItem
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: VirgilSpacing.md) {
                // Checkbox
                ZStack {
                    Circle()
                        .stroke(
                            item.isCompleted ? Color.lifesumDarkGreen : Color.gray.opacity(0.3),
                            lineWidth: 2
                        )
                        .frame(width: 24, height: 24)

                    if item.isCompleted {
                        Circle()
                            .fill(Color.lifesumDarkGreen)
                            .frame(width: 24, height: 24)

                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }

                // Icon
                Image(systemName: item.icon)
                    .font(.system(size: 14))
                    .foregroundColor(item.isCompleted ? .lifesumDarkGreen : .secondary)
                    .frame(width: 20)

                // Title
                Text(item.title)
                    .font(.subheadline)
                    .foregroundColor(item.isCompleted ? .secondary : .primary)
                    .strikethrough(item.isCompleted, color: .secondary)

                Spacer()
            }
            .padding(VirgilSpacing.md)
            .background(
                item.isCompleted ?
                Color.lifesumDarkGreen.opacity(0.05) :
                Color.lifesumCream
            )
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        @State private var items: [TodayChecklistItem] = [
            TodayChecklistItem(title: "タンパク質を毎食20g以上", icon: "fork.knife", isCompleted: true),
            TodayChecklistItem(title: "野菜を毎食取り入れる", icon: "leaf.fill", isCompleted: true),
            TodayChecklistItem(title: "水分を2L以上摂取", icon: "drop.fill", isCompleted: false),
            TodayChecklistItem(title: "間食は予定通り", icon: "clock.fill", isCompleted: false)
        ]

        var body: some View {
            ScrollView {
                TodayChecklistSection(
                    items: $items,
                    onToggle: { item in
                        if let index = items.firstIndex(where: { $0.id == item.id }) {
                            items[index].isCompleted.toggle()
                        }
                    }
                )
                .padding(.vertical)
            }
            .background(Color(.systemBackground))
        }
    }

    return PreviewWrapper()
}
