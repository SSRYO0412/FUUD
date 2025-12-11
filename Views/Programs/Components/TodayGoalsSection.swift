//
//  TodayGoalsSection.swift
//  FUUD
//
//  カロリー/PFC目標セクション
//  Phase 6-UI: TodayProgramView用
//

import SwiftUI

struct TodayGoalsSection: View {
    let targetCalories: Int
    let proteinGrams: Int
    let fatGrams: Int
    let carbsGrams: Int
    let pfc: PFCRatio

    var body: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            // Section Title
            Text("TODAY'S GOALS")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .padding(.horizontal, VirgilSpacing.md)

            // Goals Card
            VStack(spacing: VirgilSpacing.lg) {
                // Calorie Ring + Number
                calorieSection

                Divider()
                    .padding(.horizontal, VirgilSpacing.md)

                // PFC Bars
                pfcSection
            }
            .padding(VirgilSpacing.md)
            .background(Color.lifesumCream)
            .cornerRadius(12)
            .padding(.horizontal, VirgilSpacing.md)
        }
    }

    // MARK: - Calorie Section

    private var calorieSection: some View {
        HStack(spacing: VirgilSpacing.lg) {
            // Calorie Ring
            ZStack {
                Circle()
                    .stroke(Color.lifesumDarkGreen.opacity(0.2), lineWidth: 8)
                    .frame(width: 80, height: 80)

                Circle()
                    .trim(from: 0, to: 0)  // Will be animated with actual intake
                    .stroke(Color.lifesumDarkGreen, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 0) {
                    Text("\(targetCalories)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.lifesumDarkGreen)

                    Text("kcal")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }

            // Calorie Details
            VStack(alignment: .leading, spacing: VirgilSpacing.sm) {
                Text("目標カロリー")
                    .font(.headline)
                    .foregroundColor(.primary)

                Text("パーソナライズされた目標値")
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.caption2)
                        .foregroundColor(.lifesumDarkGreen)

                    Text("血液・遺伝子データで調整済み")
                        .font(.caption2)
                        .foregroundColor(.lifesumDarkGreen)
                }
            }

            Spacer()
        }
    }

    // MARK: - PFC Section

    private var pfcSection: some View {
        HStack(spacing: VirgilSpacing.md) {
            pfcBar(
                label: "P",
                fullLabel: "タンパク質",
                grams: proteinGrams,
                percentage: Int(pfc.protein),
                color: .purple
            )

            pfcBar(
                label: "F",
                fullLabel: "脂質",
                grams: fatGrams,
                percentage: Int(pfc.fat),
                color: .yellow
            )

            pfcBar(
                label: "C",
                fullLabel: "糖質",
                grams: carbsGrams,
                percentage: Int(pfc.carbs),
                color: .lifesumDarkGreen
            )
        }
    }

    private func pfcBar(label: String, fullLabel: String, grams: Int, percentage: Int, color: Color) -> some View {
        VStack(spacing: 6) {
            // Label
            Text(label)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(color)

            // Grams
            Text("\(grams)g")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)

            // Percentage
            Text("(\(percentage)%)")
                .font(.caption2)
                .foregroundColor(.secondary)

            // Full Label
            Text(fullLabel)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, VirgilSpacing.sm)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        TodayGoalsSection(
            targetCalories: 1850,
            proteinGrams: 115,
            fatGrams: 62,
            carbsGrams: 208,
            pfc: PFCRatio(protein: 25, fat: 30, carbs: 45)
        )
        .padding(.vertical)
    }
    .background(Color(.systemBackground))
}
