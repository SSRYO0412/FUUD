//
//  ProgramProgressView.swift
//  FUUD
//
//  Lifesum-style program progress view
//  Modified for Phase 6-UI: PROGRESSタブのコンテンツ
//

import SwiftUI

struct ProgramProgressView: View {
    let program: DietProgram

    @StateObject private var nutritionPersonalizer = NutritionPersonalizer.shared
    @StateObject private var programService = DietProgramService.shared
    @State private var showingCancelAlert = false

    /// キャンセル時のコールバック（ProgramContainerViewから渡される）
    var onCancel: (() -> Void)?

    private var enrollment: ProgramEnrollment? {
        programService.enrolledProgram
    }

    private var currentDay: Int {
        enrollment?.currentDay ?? 1
    }

    private var duration: Int {
        enrollment?.duration ?? 45
    }

    private var currentWeek: Int {
        (currentDay - 1) / 7 + 1
    }

    private var progressPercentage: Double {
        Double(currentDay) / Double(duration) * 100
    }

    private var currentPhase: ProgramPhase? {
        let phaseIndex = min(currentWeek - 1, program.phases.count - 1)
        return program.phases.indices.contains(phaseIndex) ? program.phases[phaseIndex] : nil
    }

    var body: some View {
        ScrollView {
            VStack(spacing: VirgilSpacing.xl) {
                // Current Phase Section
                currentPhaseSection

                // Today's Goals
                todaysGoalsSection

                // Roadmap Timeline
                roadmapTimelineSection

                // Action Buttons
                actionButtonsSection
            }
            .padding(.horizontal, VirgilSpacing.md)
            .padding(.top, VirgilSpacing.lg)
            .padding(.bottom, VirgilSpacing.xl4)
        }
        .alert("プログラムをキャンセル", isPresented: $showingCancelAlert) {
            Button("キャンセルする", role: .destructive) {
                Task {
                    await cancelProgram()
                }
            }
            Button("続ける", role: .cancel) {}
        } message: {
            Text("本当にプログラムをキャンセルしますか？進捗データは保存されません。")
        }
    }

    // MARK: - Current Phase Section

    private var currentPhaseSection: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            HStack {
                Text("今週のフェーズ: Week \(currentWeek)")
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                if let phase = currentPhase {
                    Text(phase.name)
                        .font(.subheadline)
                        .foregroundColor(.lifesumDarkGreen)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.lifesumDarkGreen.opacity(0.1))
                        .cornerRadius(4)
                }
            }

            if let phase = currentPhase, !phase.focusPoints.isEmpty {
                VStack(alignment: .leading, spacing: VirgilSpacing.sm) {
                    Text("フォーカスポイント")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)

                    ForEach(phase.focusPoints, id: \.self) { point in
                        HStack(alignment: .top, spacing: VirgilSpacing.sm) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.lifesumDarkGreen)
                                .font(.subheadline)

                            Text(point)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                        }
                    }
                }
                .padding(VirgilSpacing.md)
                .background(Color.lifesumCream)
                .cornerRadius(12)
            }
        }
    }

    // MARK: - Today's Goals Section

    private var todaysGoalsSection: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            Text("今日の目標")
                .font(.headline)
                .foregroundColor(.primary)

            VStack(spacing: VirgilSpacing.md) {
                // Calorie Target
                HStack {
                    Text("カロリー")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("\(adjustedCalories) kcal")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.lifesumDarkGreen)
                }

                // PFC Bars
                HStack(spacing: VirgilSpacing.md) {
                    pfcBar(label: "P", value: adjustedProtein, percentage: Int(currentPFC.protein), color: .purple)
                    pfcBar(label: "F", value: adjustedFat, percentage: Int(currentPFC.fat), color: .yellow)
                    pfcBar(label: "C", value: adjustedCarbs, percentage: Int(currentPFC.carbs), color: Color.lifesumDarkGreen)
                }
            }
            .padding(VirgilSpacing.md)
            .background(Color.lifesumCream)
            .cornerRadius(12)
        }
    }

    private var currentPFC: PFCRatio {
        currentPhase?.pfcOverride ?? program.basePFC
    }

    private func pfcBar(label: String, value: Int, percentage: Int, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(color)

            Text("\(value)g")
                .font(.subheadline)
                .fontWeight(.semibold)

            Text("(\(percentage)%)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, VirgilSpacing.sm)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }

    // MARK: - Roadmap Timeline Section

    private var roadmapTimelineSection: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            Text("ロードマップ")
                .font(.headline)
                .foregroundColor(.primary)

            VStack(alignment: .leading, spacing: VirgilSpacing.sm) {
                ForEach(generateRoadmap()) { week in
                    HStack(spacing: VirgilSpacing.sm) {
                        // Status Indicator
                        Circle()
                            .fill(week.isCurrentWeek ? Color.lifesumDarkGreen : (week.isPast ? Color.lifesumLightGreen : Color.gray.opacity(0.3)))
                            .frame(width: 12, height: 12)

                        // Week Info
                        Text("Week \(week.weekNumber) - \(week.phaseName)")
                            .font(.subheadline)
                            .foregroundColor(week.isFuture ? .secondary : .primary)
                            .fontWeight(week.isCurrentWeek ? .semibold : .regular)

                        Spacer()

                        // Current Badge
                        if week.isCurrentWeek {
                            Text("現在")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.lifesumDarkGreen)
                                .cornerRadius(4)
                        } else if week.isPast {
                            Image(systemName: "checkmark")
                                .font(.caption)
                                .foregroundColor(.lifesumLightGreen)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Action Buttons Section

    private var actionButtonsSection: some View {
        VStack(spacing: VirgilSpacing.md) {
            // Cancel Button
            Button {
                showingCancelAlert = true
            } label: {
                Text("プログラムをキャンセル")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - Computed Properties for Nutrition

    private var adjustedCalories: Int {
        let baseCalories = nutritionPersonalizer.adjustedCalories?.adjustedTarget ?? 1800
        let multiplier = currentPhase?.calorieMultiplier ?? 1.0
        return Int(Double(baseCalories) * multiplier)
    }

    private var adjustedProtein: Int {
        Int(Double(adjustedCalories) * currentPFC.protein / 100 / 4)
    }

    private var adjustedFat: Int {
        Int(Double(adjustedCalories) * currentPFC.fat / 100 / 9)
    }

    private var adjustedCarbs: Int {
        Int(Double(adjustedCalories) * currentPFC.carbs / 100 / 4)
    }

    // MARK: - Helper Functions

    private func generateRoadmap() -> [RoadmapWeek] {
        let totalWeeks = duration / 7
        var roadmap: [RoadmapWeek] = []
        let startDate = enrollment?.startDateParsed ?? Date()

        for weekIndex in 0..<totalWeeks {
            let phaseIndex = min(weekIndex, program.phases.count - 1)
            let phase = program.phases[phaseIndex]
            let weekStartDate = Calendar.current.date(byAdding: .day, value: weekIndex * 7, to: startDate) ?? startDate

            roadmap.append(RoadmapWeek(
                weekNumber: weekIndex + 1,
                startDate: weekStartDate,
                phaseName: phase.name,
                phaseNameEn: phase.nameEn,
                focusPoints: phase.focusPoints,
                calorieMultiplier: phase.calorieMultiplier,
                pfcOverride: phase.pfcOverride
            ))
        }

        return roadmap
    }

    private func cancelProgram() async {
        let success = await programService.cancelEnrollment()
        if success {
            onCancel?()
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        ProgramProgressView(program: DietProgramCatalog.programs[1])
    }
}
