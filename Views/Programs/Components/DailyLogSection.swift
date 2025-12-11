//
//  DailyLogSection.swift
//  FUUD
//
//  ログ導線セクション
//  Phase 6-UI: TodayProgramView用
//

import SwiftUI

struct DailyLogSection: View {
    var onWeightLog: () -> Void
    var onMealReview: () -> Void
    var onActivityLog: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            // Section Title
            Text("DAILY LOG")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .padding(.horizontal, VirgilSpacing.md)

            // Log Buttons
            HStack(spacing: VirgilSpacing.sm) {
                logButton(
                    icon: "scalemass.fill",
                    label: "体重を記録",
                    color: .blue,
                    action: onWeightLog
                )

                logButton(
                    icon: "fork.knife",
                    label: "食事を振り返る",
                    color: .orange,
                    action: onMealReview
                )

                logButton(
                    icon: "figure.run",
                    label: "運動を記録",
                    color: .green,
                    action: onActivityLog
                )
            }
            .padding(.horizontal, VirgilSpacing.md)
        }
    }

    // MARK: - Log Button

    private func logButton(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: VirgilSpacing.sm) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 48, height: 48)

                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(color)
                }

                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, VirgilSpacing.md)
            .background(Color.lifesumCream)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        DailyLogSection(
            onWeightLog: { print("Weight log tapped") },
            onMealReview: { print("Meal review tapped") },
            onActivityLog: { print("Activity log tapped") }
        )
        .padding(.vertical)
    }
    .background(Color(.systemBackground))
}
