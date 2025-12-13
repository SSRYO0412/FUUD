//
//  MorningCheckInSection.swift
//  FUUD
//
//  朝の問診セクション
//  食事予定・運動予定の表示
//

import SwiftUI

struct MorningCheckInSection: View {
    let dayContext: DayContext
    let morningPlan: MorningPlan
    let onCheckIn: () -> Void

    // Backwards compatibility initializer
    init(dayContext: DayContext, onCheckIn: @escaping () -> Void) {
        self.dayContext = dayContext
        self.morningPlan = .empty
        self.onCheckIn = onCheckIn
    }

    // New initializer with morningPlan
    init(morningPlan: MorningPlan, onCheckIn: @escaping () -> Void) {
        self.dayContext = .empty
        self.morningPlan = morningPlan
        self.onCheckIn = onCheckIn
    }

    var body: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            // Section Title
            Text("MORNING CHECK-IN")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary)
                .textCase(.uppercase)

            // Content
            if morningPlan.isEmpty {
                // 未入力: チェックインボタン
                checkInButton
            } else {
                // 入力済み: サマリー表示
                checkInSummary
            }
        }
        .padding(.horizontal, VirgilSpacing.md)
    }

    // MARK: - Check In Button

    private var checkInButton: some View {
        Button(action: onCheckIn) {
            HStack(spacing: VirgilSpacing.md) {
                ZStack {
                    Circle()
                        .fill(Color.lifesumDarkGreen.opacity(0.1))
                        .frame(width: 48, height: 48)

                    Image(systemName: "sun.horizon.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.lifesumDarkGreen)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("今日の予定を教えてください")
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text("食事と運動の予定をチェック")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(VirgilSpacing.md)
            .background(Color.lifesumCream)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Check In Summary

    private var checkInSummary: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.sm) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.lifesumDarkGreen)

                Text("チェックイン完了")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.lifesumDarkGreen)

                Spacer()

                Button(action: onCheckIn) {
                    Text("編集")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // Summary Items - Meals
            VStack(alignment: .leading, spacing: VirgilSpacing.xs) {
                // Meal Plan Row
                HStack(spacing: VirgilSpacing.sm) {
                    if let breakfast = morningPlan.breakfast {
                        mealSummaryItem(label: "朝", type: breakfast, iconColor: .orange)
                    }
                    if let lunch = morningPlan.lunch {
                        mealSummaryItem(label: "昼", type: lunch, iconColor: .yellow)
                    }
                    if let dinner = morningPlan.dinner {
                        mealSummaryItem(label: "夕", type: dinner, iconColor: .indigo)
                    }
                }

                // Exercise Row
                if let exercise = morningPlan.exercise, exercise.type != .none {
                    HStack(spacing: 4) {
                        Image(systemName: exercise.type.icon)
                            .font(.system(size: 12))
                            .foregroundColor(.lifesumLightGreen)

                        Text("\(exercise.type.displayName) \(exercise.durationMinutes)分")
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.lifesumLightGreen.opacity(0.1))
                    .cornerRadius(4)
                }
            }
        }
        .padding(VirgilSpacing.md)
        .background(Color.lifesumDarkGreen.opacity(0.05))
        .cornerRadius(12)
    }

    private func mealSummaryItem(label: String, type: PlannedMealType, iconColor: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: type.icon)
                .font(.system(size: 12))
                .foregroundColor(iconColor)

            Text("\(label):\(type.shortName)")
                .font(.caption)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.white)
        .cornerRadius(4)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        // 未入力状態
        MorningCheckInSection(
            morningPlan: .empty,
            onCheckIn: {}
        )

        Divider()

        // 入力済み状態
        MorningCheckInSection(
            morningPlan: MorningPlan(
                breakfast: PlannedMealType.homemade,
                lunch: PlannedMealType.convenience,
                dinner: PlannedMealType.eatingOut,
                exercise: ExercisePlan(type: .walking, durationMinutes: 30),
                recordedAt: Date()
            ),
            onCheckIn: {}
        )
    }
    .padding()
    .background(Color(.systemBackground))
}
