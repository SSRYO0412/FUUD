//
//  DataHabitsSection.swift
//  FUUD
//
//  MacroFactor風 Data & Habits セクション
//  参考: /Users/sasakiryo/Downloads/MacrofactorUI/MacroFactor iOS 81.png
//        /Users/sasakiryo/Downloads/MacrofactorUI/MacroFactor iOS 82.png
//

import SwiftUI

struct DataHabitsSection: View {
    @StateObject private var weightService = WeightLogService.shared
    @StateObject private var mealService = MealLogService.shared
    @StateObject private var healthKit = HealthKitService.shared

    var body: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            // Header
            Text("データ & 習慣")
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(.virgilTextSecondary)

            // Top Row: Scale Weight + Nutrition
            HStack(spacing: VirgilSpacing.md) {
                if #available(iOS 16.0, *) {
                    NavigationLink(destination: WeightTrendDetailView()) {
                        ScaleWeightMiniCard(
                            weightHistory: weightService.weightHistory,
                            currentWeight: weightService.currentWeight
                        )
                    }
                    .buttonStyle(PlainButtonStyle())

                    NavigationLink(destination: NutritionHistoryDetailView()) {
                        NutritionMiniCard(
                            weeklyData: generateWeeklyNutritionData(),
                            todayCalories: mealService.todayTotals.calories
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                } else {
                    ScaleWeightMiniCard(
                        weightHistory: weightService.weightHistory,
                        currentWeight: weightService.currentWeight
                    )

                    NutritionMiniCard(
                        weeklyData: generateWeeklyNutritionData(),
                        todayCalories: mealService.todayTotals.calories
                    )
                }
            }

            // Body Metrics Card
            if #available(iOS 16.0, *) {
                NavigationLink(destination: BodyMetricsDetailView()) {
                    BodyMetricsCard(
                        bodyFat: healthKit.healthData?.bodyFatPercentage,
                        lastUpdated: Date()
                    )
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                BodyMetricsCard(
                    bodyFat: healthKit.healthData?.bodyFatPercentage,
                    lastUpdated: Date()
                )
            }
        }
        .padding(VirgilSpacing.md)
        .liquidGlassCard()
        .onAppear {
            Task {
                await weightService.fetchWeightHistory()
                await mealService.fetchWeeklyCalories()
            }
        }
    }

    // MARK: - Helper Methods

    private func generateWeeklyNutritionData() -> [DailyNutrition] {
        let calendar = Calendar.current
        return (0..<7).map { daysAgo in
            let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()

            // デモデータ（実際のAPIデータに置き換え）
            let baseProtein = 100 + Int.random(in: -20...30)
            let baseFat = 60 + Int.random(in: -10...20)
            let baseCarbs = 180 + Int.random(in: -30...40)

            return DailyNutrition(
                date: date,
                protein: daysAgo == 0 ? mealService.todayTotals.protein : baseProtein,
                fat: daysAgo == 0 ? mealService.todayTotals.fat : baseFat,
                carbs: daysAgo == 0 ? mealService.todayTotals.carbs : baseCarbs
            )
        }.reversed()
    }
}

// MARK: - Daily Nutrition Model

struct DailyNutrition: Identifiable {
    let id = UUID()
    let date: Date
    let protein: Int
    let fat: Int
    let carbs: Int

    var totalCalories: Int {
        (protein * 4) + (fat * 9) + (carbs * 4)
    }
}

// MARK: - Scale Weight Mini Card

struct ScaleWeightMiniCard: View {
    let weightHistory: [WeightEntry]
    let currentWeight: Double?

    private var chartData: [Double] {
        if weightHistory.isEmpty {
            return [75.2, 75.0, 74.8, 74.9, 74.7, 74.5, 74.5]
        }
        return weightHistory.prefix(7).map { $0.weight }.reversed()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.sm) {
            // Title & Subtitle
            VStack(alignment: .leading, spacing: 2) {
                Text("体重")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.virgilTextPrimary)

                Text(dateRangeText)
                    .font(.system(size: 9, weight: .regular))
                    .foregroundColor(.virgilTextSecondary)
            }

            // Mini Line Chart
            MiniLineChart(data: chartData, color: Color(hex: "4ECDC4"))
                .frame(height: 40)

            // Value
            HStack {
                Text(weightText)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.virgilTextPrimary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.virgilTextSecondary)
            }
        }
        .padding(VirgilSpacing.sm)
        .background(Color.black.opacity(0.02))
        .cornerRadius(12)
    }

    private var weightText: String {
        if let current = currentWeight {
            return String(format: "%.1f kg", current)
        }
        return "-- kg"
    }

    private var dateRangeText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M/d"
        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return "\(formatter.string(from: startDate)) 〜 現在"
    }
}

// MARK: - Nutrition Mini Card

struct NutritionMiniCard: View {
    let weeklyData: [DailyNutrition]
    let todayCalories: Int

    var body: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.sm) {
            // Title & Subtitle
            VStack(alignment: .leading, spacing: 2) {
                Text("栄養摂取")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.virgilTextPrimary)

                Text(dateRangeText)
                    .font(.system(size: 9, weight: .regular))
                    .foregroundColor(.virgilTextSecondary)
            }

            // Stacked Bar Chart
            WeeklyNutritionBarChart(weekData: weeklyData)
                .frame(height: 40)

            // Value
            HStack {
                Text("\(todayCalories) kcal")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.virgilTextPrimary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.virgilTextSecondary)
            }
        }
        .padding(VirgilSpacing.sm)
        .background(Color.black.opacity(0.02))
        .cornerRadius(12)
    }

    private var dateRangeText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M/d"
        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return "\(formatter.string(from: startDate)) 〜 現在"
    }
}

// MARK: - Weekly Nutrition Bar Chart

struct WeeklyNutritionBarChart: View {
    let weekData: [DailyNutrition]

    private let proteinColor = Color(hex: "9C27B0")  // 紫
    private let fatColor = Color(hex: "FFCB05")       // 黄
    private let carbsColor = Color(hex: "00C853")     // 緑

    var body: some View {
        GeometryReader { geometry in
            let barWidth = (geometry.size.width - CGFloat(weekData.count - 1) * 4) / CGFloat(weekData.count)
            let maxCalories = weekData.map { $0.totalCalories }.max() ?? 1

            HStack(alignment: .bottom, spacing: 4) {
                ForEach(Array(weekData.enumerated()), id: \.element.id) { index, day in
                    let totalHeight = geometry.size.height * CGFloat(day.totalCalories) / CGFloat(maxCalories)
                    let proteinHeight = totalHeight * CGFloat(day.protein * 4) / CGFloat(max(day.totalCalories, 1))
                    let fatHeight = totalHeight * CGFloat(day.fat * 9) / CGFloat(max(day.totalCalories, 1))
                    let carbsHeight = totalHeight * CGFloat(day.carbs * 4) / CGFloat(max(day.totalCalories, 1))

                    VStack(spacing: 0) {
                        // Protein (top)
                        Rectangle()
                            .fill(proteinColor)
                            .frame(width: barWidth, height: proteinHeight)

                        // Fat (middle)
                        Rectangle()
                            .fill(fatColor)
                            .frame(width: barWidth, height: fatHeight)

                        // Carbs (bottom)
                        Rectangle()
                            .fill(carbsColor)
                            .frame(width: barWidth, height: carbsHeight)
                    }
                    .cornerRadius(2)
                }
            }
        }
    }
}

// MARK: - Body Metrics Card

struct BodyMetricsCard: View {
    let bodyFat: Double?
    let lastUpdated: Date

    var body: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.sm) {
            // Header
            VStack(alignment: .leading, spacing: 2) {
                Text("体組成")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.virgilTextPrimary)

                Text(formattedDate)
                    .font(.system(size: 9, weight: .regular))
                    .foregroundColor(.virgilTextSecondary)
            }

            // Body Fat
            HStack {
                Circle()
                    .fill(Color(hex: "FFCB05"))
                    .frame(width: 8, height: 8)

                Text(bodyFatText)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.virgilTextPrimary)

                Text("体脂肪率")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.virgilTextSecondary)

                Spacer()
            }

            // Footer
            HStack {
                Text(relativeDate)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.virgilTextPrimary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.virgilTextSecondary)
            }
        }
        .padding(VirgilSpacing.sm)
        .background(Color.black.opacity(0.02))
        .cornerRadius(12)
    }

    private var bodyFatText: String {
        if let bf = bodyFat {
            return String(format: "%.1f %%", bf * 100)
        }
        return "-- %"
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M月d日"
        return formatter.string(from: lastUpdated)
    }

    private var relativeDate: String {
        if Calendar.current.isDateInToday(lastUpdated) {
            return "今日"
        } else if Calendar.current.isDateInYesterday(lastUpdated) {
            return "昨日"
        } else {
            let days = Calendar.current.dateComponents([.day], from: lastUpdated, to: Date()).day ?? 0
            return "\(days)日前"
        }
    }
}

// MARK: - Preview

#if DEBUG
struct DataHabitsSection_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(.secondarySystemBackground).ignoresSafeArea()

            DataHabitsSection()
                .padding()
        }
    }
}
#endif
