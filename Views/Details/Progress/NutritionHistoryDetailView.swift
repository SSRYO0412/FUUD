//
//  NutritionHistoryDetailView.swift
//  FUUD
//
//  栄養摂取履歴詳細ページ
//  積み上げ棒グラフでPFC表示
//

import SwiftUI
import Charts

@available(iOS 16.0, *)
struct NutritionHistoryDetailView: View {
    @StateObject private var mealService = MealLogService.shared
    @StateObject private var personalizer = NutritionPersonalizer.shared

    @State private var selectedPeriod: NutritionPeriod = .sevenDays
    @State private var nutritionHistory: [DailyNutritionData] = []

    private let proteinColor = Color(hex: "9C27B0")  // 紫
    private let fatColor = Color(hex: "FFCB05")       // 黄
    private let carbsColor = Color(hex: "00C853")     // 緑

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: VirgilSpacing.lg) {
                // 今日の摂取
                todayIntakeCard

                // 期間切替 & 積み上げ棒グラフ
                chartCard

                // 平均摂取量
                averageCard

                // PFC比率
                pfcRatioCard
            }
            .padding(VirgilSpacing.md)
        }
        .background(OrbBackground())
        .navigationTitle("栄養摂取")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            generateNutritionHistory()
        }
        .onChange(of: selectedPeriod) { _ in
            generateNutritionHistory()
        }
    }

    // MARK: - Today Intake Card

    private var todayIntakeCard: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.sm) {
            Text("今日の摂取")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.virgilTextSecondary)

            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text("\(mealService.todayTotals.calories)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.virgilTextPrimary)

                Text("/ \(targetCalories) kcal")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.virgilTextSecondary)
            }

            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(hex: "0088CC"))
                        .frame(width: geometry.size.width * calorieProgress, height: 8)
                }
            }
            .frame(height: 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(VirgilSpacing.md)
        .liquidGlassCard()
    }

    // MARK: - Chart Card

    private var chartCard: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            // Period Picker
            HStack(spacing: VirgilSpacing.sm) {
                ForEach(NutritionPeriod.allCases, id: \.self) { period in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedPeriod = period
                        }
                    }) {
                        Text(period.title)
                            .font(.system(size: 12, weight: selectedPeriod == period ? .bold : .medium))
                            .foregroundColor(selectedPeriod == period ? .white : .virgilTextSecondary)
                            .padding(.horizontal, VirgilSpacing.sm)
                            .padding(.vertical, VirgilSpacing.xs)
                            .background(selectedPeriod == period ? Color.black : Color.clear)
                            .cornerRadius(8)
                    }
                }
            }

            // Stacked Bar Chart
            if !nutritionHistory.isEmpty {
                Chart(nutritionHistory) { day in
                    // Protein
                    BarMark(
                        x: .value("日付", day.date, unit: .day),
                        y: .value("タンパク質", day.proteinCalories)
                    )
                    .foregroundStyle(proteinColor)

                    // Fat
                    BarMark(
                        x: .value("日付", day.date, unit: .day),
                        y: .value("脂質", day.fatCalories)
                    )
                    .foregroundStyle(fatColor)

                    // Carbs
                    BarMark(
                        x: .value("日付", day.date, unit: .day),
                        y: .value("糖質", day.carbsCalories)
                    )
                    .foregroundStyle(carbsColor)
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel {
                            if let intValue = value.as(Int.self) {
                                Text("\(intValue)")
                                    .font(.system(size: 10))
                                    .foregroundColor(.virgilTextSecondary)
                            }
                        }
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                            .foregroundStyle(Color.gray.opacity(0.3))
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: selectedPeriod == .sevenDays ? 7 : 5)) { value in
                        AxisValueLabel {
                            if let date = value.as(Date.self) {
                                Text(formatDateShort(date))
                                    .font(.system(size: 10))
                                    .foregroundColor(.virgilTextSecondary)
                            }
                        }
                    }
                }
                .frame(height: 200)

                // Legend
                HStack(spacing: VirgilSpacing.md) {
                    legendItem(color: proteinColor, label: "P")
                    legendItem(color: fatColor, label: "F")
                    legendItem(color: carbsColor, label: "C")
                }
            }
        }
        .padding(VirgilSpacing.md)
        .liquidGlassCard()
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 12, height: 12)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.virgilTextSecondary)
        }
    }

    // MARK: - Average Card

    private var averageCard: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            Text("平均摂取量")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.virgilTextSecondary)

            VStack(spacing: VirgilSpacing.sm) {
                averageRow(label: "カロリー", value: "\(averageCalories) kcal")
                averageRow(label: "タンパク質", value: "\(averageProtein)g", color: proteinColor)
                averageRow(label: "脂質", value: "\(averageFat)g", color: fatColor)
                averageRow(label: "糖質", value: "\(averageCarbs)g", color: carbsColor)
            }
        }
        .padding(VirgilSpacing.md)
        .liquidGlassCard()
    }

    private func averageRow(label: String, value: String, color: Color = .virgilTextPrimary) -> some View {
        HStack {
            if color != .virgilTextPrimary {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
            }

            Text(label)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.virgilTextSecondary)

            Spacer()

            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.virgilTextPrimary)
        }
    }

    // MARK: - PFC Ratio Card

    private var pfcRatioCard: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            Text("PFC比率")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.virgilTextSecondary)

            // Horizontal Bar
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(proteinColor)
                        .frame(width: geometry.size.width * pfcRatio.protein)

                    Rectangle()
                        .fill(fatColor)
                        .frame(width: geometry.size.width * pfcRatio.fat)

                    Rectangle()
                        .fill(carbsColor)
                        .frame(width: geometry.size.width * pfcRatio.carbs)
                }
                .cornerRadius(6)
            }
            .frame(height: 24)

            // Percentages
            HStack {
                pfcLabel(label: "P", percent: Int(pfcRatio.protein * 100), color: proteinColor)
                Spacer()
                pfcLabel(label: "F", percent: Int(pfcRatio.fat * 100), color: fatColor)
                Spacer()
                pfcLabel(label: "C", percent: Int(pfcRatio.carbs * 100), color: carbsColor)
            }
        }
        .padding(VirgilSpacing.md)
        .liquidGlassCard()
    }

    private func pfcLabel(label: String, percent: Int, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(color)
            Text("\(percent)%")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.virgilTextPrimary)
        }
    }

    // MARK: - Computed Properties

    private var targetCalories: Int {
        personalizer.adjustedCalories?.adjustedTarget ?? 1800
    }

    private var calorieProgress: Double {
        guard targetCalories > 0 else { return 0 }
        return min(Double(mealService.todayTotals.calories) / Double(targetCalories), 1.0)
    }

    private var averageCalories: Int {
        guard !nutritionHistory.isEmpty else { return 0 }
        let total = nutritionHistory.reduce(0) { $0 + $1.totalCalories }
        return total / nutritionHistory.count
    }

    private var averageProtein: Int {
        guard !nutritionHistory.isEmpty else { return 0 }
        let total = nutritionHistory.reduce(0) { $0 + $1.protein }
        return total / nutritionHistory.count
    }

    private var averageFat: Int {
        guard !nutritionHistory.isEmpty else { return 0 }
        let total = nutritionHistory.reduce(0) { $0 + $1.fat }
        return total / nutritionHistory.count
    }

    private var averageCarbs: Int {
        guard !nutritionHistory.isEmpty else { return 0 }
        let total = nutritionHistory.reduce(0) { $0 + $1.carbs }
        return total / nutritionHistory.count
    }

    private var pfcRatio: (protein: Double, fat: Double, carbs: Double) {
        let totalCalories = Double(averageProtein * 4 + averageFat * 9 + averageCarbs * 4)
        guard totalCalories > 0 else { return (0.33, 0.33, 0.34) }

        let p = Double(averageProtein * 4) / totalCalories
        let f = Double(averageFat * 9) / totalCalories
        let c = Double(averageCarbs * 4) / totalCalories

        return (p, f, c)
    }

    // MARK: - Helper Methods

    private func generateNutritionHistory() {
        let calendar = Calendar.current
        let days = selectedPeriod.days

        nutritionHistory = (0..<days).reversed().compactMap { daysAgo in
            guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date()) else { return nil }

            // 今日のデータは実データを使用
            if daysAgo == 0 {
                return DailyNutritionData(
                    date: date,
                    protein: mealService.todayTotals.protein,
                    fat: mealService.todayTotals.fat,
                    carbs: mealService.todayTotals.carbs
                )
            }

            // 過去データはデモデータ
            return DailyNutritionData(
                date: date,
                protein: 100 + Int.random(in: -20...40),
                fat: 60 + Int.random(in: -15...25),
                carbs: 180 + Int.random(in: -40...50)
            )
        }
    }

    private func formatDateShort(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }
}

// MARK: - Nutrition Period Enum

enum NutritionPeriod: CaseIterable {
    case sevenDays
    case thirtyDays

    var title: String {
        switch self {
        case .sevenDays: return "7日"
        case .thirtyDays: return "30日"
        }
    }

    var days: Int {
        switch self {
        case .sevenDays: return 7
        case .thirtyDays: return 30
        }
    }
}

// MARK: - Daily Nutrition Data

struct DailyNutritionData: Identifiable {
    let id = UUID()
    let date: Date
    let protein: Int
    let fat: Int
    let carbs: Int

    var totalCalories: Int {
        (protein * 4) + (fat * 9) + (carbs * 4)
    }

    var proteinCalories: Int { protein * 4 }
    var fatCalories: Int { fat * 9 }
    var carbsCalories: Int { carbs * 4 }
}

// MARK: - Preview

#if DEBUG
@available(iOS 16.0, *)
struct NutritionHistoryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NutritionHistoryDetailView()
        }
    }
}
#endif
