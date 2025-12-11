//
//  TodayFocusSection.swift
//  FUUD
//
//  フォーカスプランセクション
//  Phase 6-UI: TodayProgramView用
//

import SwiftUI

struct TodayFocusSection: View {
    let phase: ProgramPhase?
    let program: DietProgram?

    var body: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            // Section Title
            Text("TODAY'S FOCUS")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .padding(.horizontal, VirgilSpacing.md)

            // Focus Card
            VStack(alignment: .leading, spacing: VirgilSpacing.md) {
                // Phase Header
                if let phase = phase {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(phase.name)
                                .font(.headline)
                                .foregroundColor(.primary)

                            if !phase.nameEn.isEmpty && phase.nameEn != phase.name {
                                Text(phase.nameEn)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }

                        Spacer()

                        // Calorie multiplier badge
                        if phase.calorieMultiplier != 1.0 {
                            calorieAdjustmentBadge(multiplier: phase.calorieMultiplier)
                        }
                    }
                }

                // Focus Points
                if let focusPoints = phase?.focusPoints, !focusPoints.isEmpty {
                    VStack(alignment: .leading, spacing: VirgilSpacing.sm) {
                        ForEach(focusPoints, id: \.self) { point in
                            HStack(alignment: .top, spacing: VirgilSpacing.sm) {
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.lifesumDarkGreen)

                                Text(point)
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }

                // Program Layer Info
                if let program = program {
                    Divider()

                    HStack(spacing: VirgilSpacing.md) {
                        layerBadge(layer: program.layer)

                        if program.canStackWithFasting {
                            stackBadge(icon: "clock.arrow.circlepath", label: "断食OK")
                        }

                        if program.canStackWithFocus {
                            stackBadge(icon: "target", label: "フォーカス追加可")
                        }

                        Spacer()
                    }
                }
            }
            .padding(VirgilSpacing.md)
            .background(Color.lifesumCream)
            .cornerRadius(12)
            .padding(.horizontal, VirgilSpacing.md)
        }
    }

    // MARK: - Calorie Adjustment Badge

    private func calorieAdjustmentBadge(multiplier: Double) -> some View {
        let percentChange = Int((multiplier - 1.0) * 100)
        let prefix = percentChange >= 0 ? "+" : ""

        return Text("\(prefix)\(percentChange)% kcal")
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(percentChange < 0 ? .orange : .blue)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                (percentChange < 0 ? Color.orange : Color.blue).opacity(0.1)
            )
            .cornerRadius(4)
    }

    // MARK: - Layer Badge

    private func layerBadge(layer: ProgramLayer) -> some View {
        let (icon, color) = layerInfo(layer)

        return HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))

            Text(layer.displayNameJa)
                .font(.system(size: 10, weight: .medium))
        }
        .foregroundColor(color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
        .cornerRadius(4)
    }

    private func layerInfo(_ layer: ProgramLayer) -> (String, Color) {
        switch layer {
        case .base:
            return ("square.stack.3d.up.fill", .blue)
        case .timing:
            return ("clock.fill", .orange)
        case .focus:
            return ("scope", .purple)
        case .calibration:
            return ("slider.horizontal.3", .gray)
        }
    }

    // MARK: - Stack Badge

    private func stackBadge(icon: String, label: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))

            Text(label)
                .font(.system(size: 10, weight: .medium))
        }
        .foregroundColor(.secondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(4)
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        TodayFocusSection(
            phase: ProgramPhase(
                id: "week-1",
                weekNumber: 1,
                name: "導入期",
                nameEn: "Introduction",
                description: "体を慣らしていく期間",
                focusPoints: [
                    "糖質を1日100g以下に抑える",
                    "水分を2L以上摂取する",
                    "良質な脂質を意識的に摂取"
                ],
                calorieMultiplier: 0.9,
                pfcOverride: nil
            ),
            program: DietProgramCatalog.programs.first
        )
        .padding(.vertical)
    }
    .background(Color(.systemBackground))
}
