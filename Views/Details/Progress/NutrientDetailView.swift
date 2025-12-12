//
//  NutrientDetailView.swift
//  FUUD
//
//  個別栄養素詳細ページ
//  7日間の棒グラフ表示
//

import SwiftUI
import Charts

@available(iOS 16.0, *)
struct NutrientDetailView: View {
    let nutrientType: NutrientType

    @StateObject private var mealService = MealLogService.shared
    @StateObject private var personalizer = NutritionPersonalizer.shared

    @State private var weeklyData: [NutrientDayData] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: VirgilSpacing.lg) {
                // 今日の摂取
                todayIntakeCard

                // 7日間推移
                chartCard

                // 食品別内訳
                foodBreakdownCard

                // 目標設定
                goalSettingsCard
            }
            .padding(VirgilSpacing.md)
        }
        .background(OrbBackground())
        .navigationTitle(nutrientType.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            generateWeeklyData()
        }
    }

    // MARK: - Today Intake Card

    private var todayIntakeCard: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            Text("今日の摂取")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.virgilTextSecondary)

            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text("\(currentValue)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.virgilTextPrimary)

                Text("/ \(targetValue) \(nutrientType.unit)")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.virgilTextSecondary)
            }

            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 12)

                    RoundedRectangle(cornerRadius: 6)
                        .fill(nutrientType.color)
                        .frame(width: geometry.size.width * min(progress, 1.0), height: 12)
                        .animation(.easeOut(duration: 0.5), value: progress)
                }
            }
            .frame(height: 12)

            HStack {
                Text("\(percentage)%")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(progressTextColor)

                Text("達成")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.virgilTextSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(VirgilSpacing.md)
        .liquidGlassCard()
    }

    // MARK: - Chart Card

    private var chartCard: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            Text("7日間推移")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.virgilTextSecondary)

            if !weeklyData.isEmpty {
                Chart {
                    // 目標ライン
                    RuleMark(y: .value("目標", targetValue))
                        .foregroundStyle(Color(hex: "00C853").opacity(0.5))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                        .annotation(position: .top, alignment: .trailing) {
                            Text("目標")
                                .font(.system(size: 9))
                                .foregroundColor(Color(hex: "00C853"))
                        }

                    ForEach(weeklyData) { day in
                        BarMark(
                            x: .value("日付", day.date, unit: .day),
                            y: .value(nutrientType.title, day.value)
                        )
                        .foregroundStyle(day.value >= targetValue ? Color(hex: "00C853") : Color.gray.opacity(0.5))
                        .cornerRadius(4)
                    }
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
                    AxisMarks(values: .stride(by: .day)) { value in
                        AxisValueLabel {
                            if let date = value.as(Date.self) {
                                Text(dayOfWeek(date))
                                    .font(.system(size: 10))
                                    .foregroundColor(.virgilTextSecondary)
                            }
                        }
                    }
                }
                .frame(height: 180)

                // Legend
                HStack(spacing: VirgilSpacing.md) {
                    legendItem(color: Color(hex: "00C853"), label: "達成")
                    legendItem(color: Color.gray.opacity(0.5), label: "未達成")
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
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(.virgilTextSecondary)
        }
    }

    // MARK: - Food Breakdown Card

    private var foodBreakdownCard: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            Text("食品別内訳")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.virgilTextSecondary)

            VStack(spacing: VirgilSpacing.sm) {
                ForEach(topFoods, id: \.name) { food in
                    foodRow(name: food.name, value: food.value)
                }

                if topFoods.isEmpty {
                    Text("今日の食事記録がありません")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.virgilTextSecondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, VirgilSpacing.md)
                }
            }
        }
        .padding(VirgilSpacing.md)
        .liquidGlassCard()
    }

    private func foodRow(name: String, value: Int) -> some View {
        HStack {
            Text(name)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.virgilTextPrimary)

            Spacer()

            Text("\(value) \(nutrientType.unit)")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.virgilTextSecondary)
        }
    }

    // MARK: - Goal Settings Card

    private var goalSettingsCard: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            Text("目標設定")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.virgilTextSecondary)

            VStack(spacing: VirgilSpacing.sm) {
                settingRow(label: "目標", value: "\(targetValue) \(nutrientType.unit)/日")

                if nutrientType == .protein, let weight = mealService.todayTotals.calories > 0 ? 74.0 : nil {
                    settingRow(label: "体重1kgあたり", value: String(format: "%.1f g", Double(targetValue) / weight))
                }

                if nutrientType == .calories {
                    settingRow(label: "目的", value: goalDescription)
                }
            }
        }
        .padding(VirgilSpacing.md)
        .liquidGlassCard()
    }

    private func settingRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.virgilTextSecondary)

            Spacer()

            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.virgilTextPrimary)
        }
    }

    // MARK: - Computed Properties

    private var currentValue: Int {
        switch nutrientType {
        case .calories:
            return mealService.todayTotals.calories
        case .protein:
            return mealService.todayTotals.protein
        case .fat:
            return mealService.todayTotals.fat
        case .carbs:
            return mealService.todayTotals.carbs
        }
    }

    private var targetValue: Int {
        let targetCalories = personalizer.adjustedCalories?.adjustedTarget ?? 1800

        switch nutrientType {
        case .calories:
            return targetCalories
        case .protein:
            return personalizer.pfcBalance.proteinGrams(for: targetCalories)
        case .fat:
            return personalizer.pfcBalance.fatGrams(for: targetCalories)
        case .carbs:
            return personalizer.pfcBalance.carbsGrams(for: targetCalories)
        }
    }

    private var progress: Double {
        guard targetValue > 0 else { return 0 }
        return Double(currentValue) / Double(targetValue)
    }

    private var percentage: Int {
        Int(progress * 100)
    }

    private var progressTextColor: Color {
        if percentage >= 100 {
            return Color(hex: "00C853")
        } else if percentage >= 80 {
            return Color(hex: "FFCB05")
        } else {
            return Color(hex: "FF6B6B")
        }
    }

    private var goalDescription: String {
        let tdee = personalizer.adjustedCalories?.baseTDEE ?? 2100
        let diff = targetValue - tdee

        if diff < -200 { return "減量" }
        else if diff > 200 { return "増量" }
        else { return "維持" }
    }

    private var topFoods: [(name: String, value: Int)] {
        // デモデータ
        switch nutrientType {
        case .calories:
            return [
                ("鶏胸肉 150g", 248),
                ("玄米ご飯 200g", 330),
                ("プロテイン", 120),
                ("卵 2個", 156),
                ("サラダ", 85)
            ]
        case .protein:
            return [
                ("鶏胸肉 150g", 45),
                ("プロテイン", 30),
                ("卵 2個", 18),
                ("豆腐", 12),
                ("魚", 20)
            ]
        case .fat:
            return [
                ("アボカド", 15),
                ("ナッツ", 12),
                ("オリーブオイル", 10),
                ("卵 2個", 11),
                ("チーズ", 8)
            ]
        case .carbs:
            return [
                ("玄米ご飯 200g", 74),
                ("パスタ", 55),
                ("フルーツ", 25),
                ("パン", 30),
                ("野菜", 15)
            ]
        }
    }

    // MARK: - Helper Methods

    private func generateWeeklyData() {
        let calendar = Calendar.current

        weeklyData = (0..<7).reversed().compactMap { daysAgo in
            guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date()) else { return nil }

            // 今日のデータは実データ
            if daysAgo == 0 {
                return NutrientDayData(date: date, value: currentValue)
            }

            // 過去データはデモデータ
            let baseValue = targetValue
            let variation = Int.random(in: -30...30)
            let value = max(0, baseValue + variation)

            return NutrientDayData(date: date, value: value)
        }
    }

    private func dayOfWeek(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
}

// MARK: - Nutrient Type Enum

enum NutrientType: CaseIterable {
    case calories
    case protein
    case fat
    case carbs

    var title: String {
        switch self {
        case .calories: return "カロリー"
        case .protein: return "タンパク質"
        case .fat: return "脂質"
        case .carbs: return "糖質"
        }
    }

    var unit: String {
        switch self {
        case .calories: return "kcal"
        case .protein, .fat, .carbs: return "g"
        }
    }

    var color: Color {
        switch self {
        case .calories: return Color(hex: "0088CC")
        case .protein: return Color(hex: "9C27B0")
        case .fat: return Color(hex: "FFCB05")
        case .carbs: return Color(hex: "00C853")
        }
    }
}

// MARK: - Nutrient Day Data

struct NutrientDayData: Identifiable {
    let id = UUID()
    let date: Date
    let value: Int
}

// MARK: - Preview

#if DEBUG
@available(iOS 16.0, *)
struct NutrientDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NutrientDetailView(nutrientType: .protein)
        }
    }
}
#endif
